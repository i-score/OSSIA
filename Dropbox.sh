#!/bin/bash -x

### Script to automate dropbox deployment on the CI machine ###
###### Build using all the cores ######
ARCH=`uname -m`
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
	DISTRO=$(cat /etc/lsb-release | grep DISTRIB_ID | cut -f2 -d=)
	DISTROVERSION=$(cat /etc/lsb-release | grep DISTRIB_RELEASE | cut -f2 -d=)
elif [[ "$OSTYPE" == "darwin"* ]]; then
	DISTRO="OS X"
fi

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
	FOLDER="/home/ossia/Dropbox/Iscore/Releases/$DISTRO$DISTROVERSION/$ARCH"
#	cp build/jamoma/Jamomacore-0.6-dev-Linux.deb $FOLDER

	tar -cJf i-score0.2.tar.xz i-score0.2
#	cp i-score0.2 $FOLDER
	
elif [[ "$OSTYPE" == "darwin"* ]]; then
	zip -r i-score0.2.zip $ISCORE_EXECUTABLE_NAME.app
	cp i-score0.2.zip "/Users/jcelerier/Dropbox/Iscore/Releases/$DISTRO/"

fi
