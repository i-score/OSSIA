#!/bin/bash -x
########################################
###### Intro & Parameter handling ######
########################################
ISCORE_CMAKE_DEBUG=""
ISCORE_QMAKE_DEBUG=""
ISCORE_CMAKE_TOOLCHAIN=""
ISCORE_QMAKE_TOOLCHAIN=""

ISCORE_BREW_UNIVERSAL_FLAGS=""
ISCORE_CMAKE_UNIVERSAL_FLAGS=""

ISCORE_DEPTH_GIT="--depth=1"
ISCORE_FOLDER="i-score"

ISCORE_JAMOMA_BRANCH="feature/cmake"
ISCORE_JAMOMAMAX_BRANCH="feature/cmake"
ISCORE_SCORE_BRANCH="feature/cmake"
ISCORE_ISCORE_BRANCH="dev"

ISCORE_BREW_FLAGS="--build-bottle"
ISCORE_CMAKE_PD_FLAGS="-DDONT_BUILD_JAMOMAPD:bool==True"  # don't build JamomaPd for now

source settings.sh

function fixup_deb_pkg {
	PKG=$1
	echo "Fixing package : $PKG"
	echo
	mkdir fix_up_deb
	dpkg-deb -x $PKG fix_up_deb
	dpkg-deb --control $PKG fix_up_deb/DEBIAN
	rm $PKG
	chmod 0644 fix_up_deb/DEBIAN/md5sums
	find -type d -print0 |xargs -0 chmod 755
	fakeroot dpkg -b fix_up_deb $PKG
	rm -rf fix_up_deb
}

HELP_MESSAGE="Usage : $(basename "$0") [software] [options]
Builds Jamoma, Score, and i-score 0.2, 0.3 on Linux and OS X systems.

Software :
iscore
  Builds and packages i-score. Requires jamoma to be installed.
	(Calling the script with jamoma will do)

i-score_player
  Builds the i-score command-line player. Requires jamoma to be installed.

jamoma
  Builds and installs Jamoma on the system folders, or creates release packages.

Options :
--clone
  Clones the git repositories.
--fetch-all
  Fetches the full git repositories instead of the tip of the feature/cmake branch. Useful for development.

--install-deps
  Installs dependencies using apt-get / yum on Linux and brew / port on OS X.

--no-jamoma-pd
  Does not build Jamoma PureData implementation.
--no-jamoma-max
  Does not build Jamoma Max implementation. Only effective on OS X (since there is no Max on Linux)
--debug
  Builds everything with debug informations.
--use-clang
  Builds everything with the Clang compiler. Only useful on Linux systems.
--multi
  Builds using all your cores.
--android
  Cross-build for Android. Only i-score 0.3. Requires the NDK & a toolchain with compiled libs. See AndroidBuild.txt.
  To cross-build, please set ANDROID_NDK_ROOT to your NDK path and ANDROID_QT_BIN to the corresponding qmake executable folder.
--universal
	Builds an universal binary for OS X. Warning: does not work well with brew; portmidi and gecode have to be built by hand

--optimize
  Builds with optimizations enabled. More speed, but is not suitable for distribution on older computers or different processors.
--clean
  Removes the build folder and the executables prior to building.
--uninstall
  Will try to uninstall Jamoma.

--help
  Shows this message

"

while test $# -gt 0
do
	case "$1" in
	--help) echo "$HELP_MESSAGE"
		exit
		;;
	--debug) echo "Debug build"
		ISCORE_CMAKE_DEBUG="-DCMAKE_BUILD_TYPE=Debug"
		ISCORE_QMAKE_DEBUG="CONFIG+=debug"
		;;
	--use-clang) echo "Build uses Clang (only for Linux)"
		ISCORE_USE_CLANG=1
		;;
	--android) echo "Android cross-build (only Jamoma for now, i-score needs to be ported to Qt5.x)"
		OSTYPE="android"
		;;
	--install-deps) echo "Required dependencies will be installed"
		ISCORE_INSTALL_DEPS=1
		;;
	--clone) echo "Will clone the git repositories"
		ISCORE_CLONE_GIT=1
		;;
	--fetch-all) echo "Will fetch the entire repositories. Useful for development".
		ISCORE_FETCH_GIT=1
		ISCORE_DEPTH_GIT=""
		;;
	--classic) echo "Will build using the Ruby script"
		ISCORE_CLASSIC_BUILD=1
		;;
	--clean-classic) echo "Will clean the classic stuff"
		ISCORE_CLEAN_CLASSIC_BUILD=1
		;;
	--jamoma-path=*)
		ISCORE_JAMOMA_PATH=$(cd "${1#*=}"; pwd)
		echo "Will use the Jamoma installation located in ${ISCORE_JAMOMA_PATH}"
		;;
	--multi) echo "Will build using every logical core on the computer (faster)"
		ISCORE_ENABLE_MULTICORE=1
		;;
	--master) echo "Using the master branch"
		ISCORE_SCORE_BRANCH="master"
		ISCORE_ISCORE_BRANCH="master"
		;;
	--optimize) echo "Optimized build"
		ISCORE_BREW_FLAGS=""
		CFLAGS="-Ofast -march=native"
		CXXFLAGS="$CFLAGS"
		;;
	--universal) echo "OS X only: Universal build (i386; x86_64)"
		ISCORE_BREW_UNIVERSAL_FLAGS="--universal"
		ISCORE_CMAKE_UNIVERSAL_FLAGS="-DCMAKE_OSX_ARCHITECTURES=x86_64;i386"
		;;
	--uninstall) echo "Will uninstall Jamoma"
		ISCORE_UNINSTALL_JAMOMA=1
		;;

	--no-jamoma-pd) echo "Will not install JamomaPd"
		ISCORE_CMAKE_PD_FLAGS="-DDONT_BUILD_JAMOMAPD:bool==True"
		;;
	--no-jamoma-max) echo "Will not install JamomaMax"
		ISCORE_CMAKE_MAX_FLAGS="-DDONT_BUILD_JAMOMAMAX:bool==True"
		;;

	i-score_player) echo "Will build the command line player"
		ISCORE_INSTALL_PLAYER=1
	  ;;
	iscore) echo "Will build iscore"
		ISCORE_INSTALL_ISCORE=1
		;;
	jamoma) echo "Will install Jamoma in the system folders"
		ISCORE_INSTALL_JAMOMA=1
		;;
	--clean) echo "Removal of the build folder"
		rm -rf build
		;;
	*) echo "Wrong option : $1"
		echo "$HELP_MESSAGE"
		exit 1
		;;
	esac
	shift
done

########## GENERAL CONFIG ##########
###### Check of the Linux distribution ######
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  ISCORE_CMAKE_MAX_FLAGS="-DDONT_BUILD_JAMOMAMAX:bool==True" # don't need to try to build JamomaMax under Linux
	if [ -f /etc/fedora-release ] ; then # yum
		ISCORE_FEDORA=1
	elif [[ `lsb_release -si` = 'Debian' || `lsb_release -si` = 'Ubuntu' || `lsb_release -si` = 'LinuxMint' || -f /etc/debian_version ]]; then # apt
		ISCORE_DEBIAN=1
	fi
fi

###### Build using all the cores ######
if [[ $ISCORE_ENABLE_MULTICORE ]]; then
	if [[ "$OSTYPE" == "linux-gnu"* ]]; then
		ISCORE_NUM_THREADS=`nproc`
	elif [[ "$OSTYPE" == "darwin"* ]]; then
		ISCORE_NUM_THREADS=`sysctl -n hw.ncpu`
	fi
else
	ISCORE_NUM_THREADS=1
fi


#####################################
######### Standard Build ############
#####################################


####### Uninstallation ? #############
if [[ $ISCORE_UNINSTALL_JAMOMA ]]; then
	if [[ $ISCORE_FEDORA ]]; then
		su -c 'yum remove jamomacore'
		sudo rm -rf /usr/lib/libJamoma*

	elif [[ $ISCORE_DEBIAN ]]; then
		sudo apt-get -y remove jamomacore
		sudo rm -rf /usr/lib/libJamoma*

	elif [[ "$OSTYPE" == "darwin"* ]]; then
		sudo rm -rf /usr/local/jamoma*
	fi

	exit 0
fi



###### Set compiler toolchains ######
if [[ $ISCORE_USE_CLANG ]]; then
	if [[ "$OSTYPE" == "android"* ]]; then
	ISCORE_CMAKE_TOOLCHAIN="-DCMAKE_TOOLCHAIN_FILE=../../Jamoma/Core/Shared/CMake/toolchains/android-clang.cmake"
	ISCORE_QMAKE_TOOLCHAIN="-spec android-clang"
	elif [[ "$OSTYPE" != "darwin"* ]]; then
	ISCORE_CMAKE_TOOLCHAIN="-DCMAKE_TOOLCHAIN_FILE=../../Jamoma/Core/Shared/CMake/toolchains/linux-clang.cmake"
	ISCORE_QMAKE_TOOLCHAIN="-spec linux-clang"
	fi
else
	if [[ "$OSTYPE" == "android"* ]]; then
	ISCORE_CMAKE_TOOLCHAIN="-DCMAKE_TOOLCHAIN_FILE=../../Jamoma/Core/Shared/CMake/toolchains/android-gcc.cmake"
	ISCORE_QMAKE_TOOLCHAIN="-spec android-g++"
	fi
fi

###### Install dependencies ######
if [[ $ISCORE_INSTALL_DEPS ]]; then
	if [[ "$OSTYPE" == "linux-gnu"* ]]; then # Desktop & Embedded Linux

		if [[ $ISCORE_FEDORA ]]; then
			su -c 'yum install qt5-qtbase qt5-qtbase-devel qt5-qttools qt5-qtsvg qt5-qtsvg-devel cmake git gecode-devel libxml2-devel libsndfile-devel portaudio-devel portmidi portmidi-tools portmidi-devel libstdc++-devel wget'
		elif [[ $ISCORE_DEBIAN ]]; then
			sudo apt-get -y install libgecode-dev g++ qtchooser qt5-default qt5-qmake qtbase5-dev qtbase5-dev-tools libqt5svg5-dev qtdeclarative5-dev libqt5svg5-dev cmake git libgl1-mesa-dev libxml2-dev libsndfile-dev portaudio19-dev libportmidi-dev clang-3.4 libstdc++-4.8-dev libc++-dev wget fakeroot
		fi

	elif [[ "$OSTYPE" == "darwin"* ]]; then # Mac OS X
		if command which brew; then # Brew
			brew update
			brew install cmake wget # Tools, no need for fancy build options

			# The libraries we use
			declare -a brew_pkgs=("gecode" "portaudio" "portmidi" "libsndfile")
			for PKG in "${brew_pkgs[@]}"
			do
				brew install $PKG $ISCORE_BREW_FLAGS $ISCORE_BREW_UNIVERSAL_FLAGS
				brew postinstall $PKG
			done

			brew install qt5 # It's already a bottle, it would take too much time to build.
			brew link gecode
			brew linkapps
		elif command which port; then # MacPorts
			sudo port install cmake gecode portaudio portmidi libsndfile qt5-mac wget
		else
			echo "Warning : --install-deps was specified but no suitable package manager was found.
				  Please install Homebrew or Macports."
			exit
		fi
	fi
fi

###### Configure qmake ######
ISCORE_QMAKE=qmake

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
	if [[ $ISCORE_FEDORA ]]; then
		ISCORE_QMAKE=qmake-qt5
	elif command which qtchooser; then
		ISCORE_QMAKE="qtchooser -run-tool=qmake -qt=qt5"
	fi
fi

########################################
#####         Installation         #####
########################################

##### Cloning #####
if [[ $ISCORE_CLONE_GIT ]]; then
	# Jamoma
	export GIT_SSL_NO_VERIFY=1
	
	git clone https://github.com/Jamoma/Jamoma
	git clone -b $ISCORE_JAMOMA_BRANCH https://github.com/i-score/JamomaCore.git Jamoma/Core $ISCORE_DEPTH_GIT

	if [[ "$OSTYPE" != "linux-gnu"* ]]; then
		git clone -b $ISCORE_JAMOMAMAX_BRANCH https://github.com/jamoma/JamomaMax.git Jamoma/Implementations/Max $ISCORE_DEPTH_GIT #todo
	fi

	git clone -b $ISCORE_SCORE_BRANCH https://github.com/i-score/Score.git Jamoma/Core/Score $ISCORE_DEPTH_GIT

	export ISCORE_JAMOMA_PATH=`pwd`/Jamoma
	

	git clone -b $ISCORE_ISCORE_BRANCH https://github.com/i-score/i-score.git $ISCORE_FOLDER $ISCORE_DEPTH_GIT
	
	if [[ $ISCORE_FETCH_GIT ]]; then
		(cd $ISCORE_JAMOMA_PATH/Core; git fetch --all)
		(cd $ISCORE_JAMOMA_PATH/Core/Score; git fetch --all)
		(cd $ISCORE_JAMOMA_PATH/Implementations/Max; git fetch --all)
		(cd $ISCORE_FOLDER; git fetch --all)
	fi
fi


##### Build Jamoma #####
# Path setting
if [[ ! $ISCORE_JAMOMA_PATH ]]; then
	export ISCORE_JAMOMA_PATH=`pwd`/Jamoma
fi
export JAMOMA_INCLUDE_PATH=$ISCORE_JAMOMA_PATH/Core

# Create build folders
mkdir -p build/jamoma
cd build/jamoma

# Build
if [[ $ISCORE_INSTALL_JAMOMA ]]; then
	cmake "$ISCORE_JAMOMA_PATH/Core" $ISCORE_CMAKE_DEBUG $ISCORE_CMAKE_UNIVERSAL_FLAGS $ISCORE_CMAKE_MAX_FLAGS $ISCORE_CMAKE_PD_FLAGS $ISCORE_CMAKE_TOOLCHAIN

	if [ $? -ne 0 ]; then
		exit 1
	fi

	# Creation of Jamoma packages
	if [[ "$OSTYPE" == "linux-gnu"* ]]; then # Desktop & Embedded Linux
		if [[ $ISCORE_FEDORA ]]; then # RPM
			cpack -G RPM
			if [ $? -ne 0 ]; then
				exit 1
			fi

			# Install
			su -c 'rpm -Uvh --force JamomaCore-0.6-dev-Linux.rpm'
			su -c 'ln -s /usr/local/lib/jamoma/lib/* -t /usr/lib'

		elif [[ $ISCORE_DEBIAN ]]; then # DEB
			make -j$ISCORE_NUM_THREADS package
			if [ $? -ne 0 ]; then
				exit 1
			fi

			# Install
			fixup_deb_pkg JamomaCore-0.6-dev-Linux.deb
			sudo dpkg -i JamomaCore-0.6-dev-Linux.deb
			cp JamomaCore-0.6-dev-Linux.deb ../../

		else
			echo "Warning : no suitable packaging method found. Please package Jamoma yourself or run make install."
		fi
	elif [[ "$OSTYPE" == "android" ]]; then # Android
		make -j$ISCORE_NUM_THREADS
		sudo cp *.so /opt/android-toolchain/arm-linux-androideabi/lib/jamoma
	elif [[ "$OSTYPE" == "darwin"* ]]; then # Mac OS X
		make -j$ISCORE_NUM_THREADS && sudo make install
		if [ $? -ne 0 ]; then
			exit 1
		fi

		sudo cpack -G TGZ
		if [ $? -ne 0 ]; then
			exit 1
		fi
    sudo chown $USER JamomaCore-0.6-dev-Darwin.tar.gz
    sudo chmod a+rw JamomaCore-0.6-dev-Darwin.tar.gz
		cp JamomaCore-0.6-dev-Darwin.tar.gz ../../
	else
		echo "Not supported yet."
	fi
fi

##### BUILD COMMAND LINE PLAYER ######
if [[ $ISCORE_INSTALL_PLAYER ]]; then
	(
	  mkdir -p build/iscore_player
		cd build/iscore_player
		cmake $ISCORE_JAMOMA_PATH/Core/Score/implementations/i-score $ISCORE_CMAKE_DEBUG $ISCORE_CMAKE_TOOLCHAIN
		make -j$ISCORE_NUM_THREADS
		make install
	)
fi

##### Build i-score #####
if [[ $ISCORE_INSTALL_ISCORE ]]; then
	if [[ "$OSTYPE" == "linux-gnu"* ]]; then # Desktop & Embedded Linux
		#
		(
			cd ../../$ISCORE_FOLDER/;
			if [[ ! -f installer_data.zip ]]; then
				wget "https://www.dropbox.com/sh/iwqky9vh1xuu9qq/AAAaWdkqHHDFGiVDr05jUxrra?dl=1" -O installer_data.zip;
				unzip installer_data.zip -d installer_data;
			fi
		)
		# Build i-score
		cd ..
		mkdir $ISCORE_FOLDER

		cd $ISCORE_FOLDER

		cmake ../../$ISCORE_FOLDER -DCMAKE_BUILD_TYPE=Release
		make -j$ISCORE_NUM_THREADS
		if [ $? -ne 0 ]; then
			exit 1
		fi
		make package

		fixup_deb_pkg i-score-0.2.3-Linux.deb
		cp i-score-0.2.3-Linux.deb ../..

	elif [[ "$OSTYPE" == "android" ]]; then # Android
		cd ..
		mkdir $ISCORE_FOLDER
		cd $ISCORE_FOLDER
		mkdir android_build_output

		echo "Using following NDK root : $ANDROID_NDK_ROOT."
		$ANDROID_QT_BIN/qmake -r $ISCORE_QMAKE_TOOLCHAIN $ISCORE_QMAKE_DEBUG ../../$ISCORE_FOLDER/i-scoreNew.pro
		make -j$ISCORE_NUM_THREADS
		make install INSTALL_ROOT=android_build_output
		$ANDROID_QT_BIN/androiddeployqt --output android_build_output --input android-libi-scoreRecast.so-deployment-settings.json

		cp android_build_output/bin/QtApp-debug.apk ../../i-score-debug.apk

	elif [[ "$OSTYPE" == "darwin"* ]]; then # Mac OS X
	    cd ..
	    mkdir $ISCORE_FOLDER
	    cd $ISCORE_FOLDER

	    if [[ -z "$ISCORE_QT_PATH" ]]; then
		    ISCORE_CMAKE_QT_CONFIG="$(find /usr/local/Cellar/qt5 -name Qt5Config.cmake)"
		    ISCORE_CMAKE_QT_PATH="$(dirname $(dirname $ISCORE_CMAKE_QT_CONFIG))"
	    else
		    ISCORE_CMAKE_QT_PATH="$ISCORE_QT_PATH/lib/cmake"
	   fi

	    (
	      cd ../../$ISCORE_FOLDER/;
	      if [[ ! -f installer_data.zip ]]; then
	        wget "https://www.dropbox.com/sh/iwqky9vh1xuu9qq/AAAaWdkqHHDFGiVDr05jUxrra?dl=1" -O installer_data.zip;
	        unzip installer_data.zip -d installer_data;
	      fi
	    )


	    cmake ../../$ISCORE_FOLDER -DCMAKE_PREFIX_PATH="$ISCORE_CMAKE_QT_PATH/Qt5;$ISCORE_CMAKE_QT_PATH/Qt5Widgets;$ISCORE_CMAKE_QT_PATH/Qt5Test;$ISCORE_CMAKE_QT_PATH/Qt5Gui;$ISCORE_CMAKE_QT_PATH/Qt5Xml;$ISCORE_CMAKE_QT_PATH/Qt5Core;/usr/local/jamoma/lib" -DCMAKE_BUILD_TYPE=Release
	    make -j$ISCORE_NUM_THREADS
	    if [ $? -ne 0 ]; then
	      exit 1
	    fi

	    sudo make package
	    sudo chown $USER i-score.dmg
	    sudo chmod a+rw i-score.dmg
	    cp i-score.dmg ../..

	else
		echo "System not supported yet."
	fi
fi
