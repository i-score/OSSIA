OSSIA
=====

The base repository for the OSSIA project. Contains initialization and build scripts.

For now, there is a build script that works for Unix OSes.
Every command are detailed when called with `--help`.

They were tested on Mac OS X 10.9, Win8, Debian Jessie, Fedora 19, Ubuntu 14.04 and Ubuntu 13.10.
Please refer to the additional notes prior to running the commands.

Required OS versions: MacOS 10.7 and above, Win7 and above, Ubuntu 14.04 and above.

# Setup 
### (Requires brew / macports on OS X)
(see instructions below to install brew for OSX)

If you want to try the current i-score release quickly, run : 

    ./Build.sh jamoma iscore --clone --install-deps
    
Which will clone several repositories (Jamoma, Jamoma/Core and i-score) as sub-folders of this repository's folder
and will create an i-score0.2 executable file on Linux, and an i-score0.2.app on OS X.
This (with the --install-deps option) will also install all dependencies, including Qt5, gecode and others…

If you want to try the next version of i-score (0.3), which is only at the prototype state run : 

    ./Build.sh jamoma iscore-recast --clone --install-deps
    
Which will create an i-score0.3 executable file on Linux, and an i-score0.3.app on OS X.

# Setup for developers
In the name of quickness, the commands only fetch the latest git commits, which can be a problem if you want to develop, switch branches, etc...

So if you want to develop, please add the `--fetch-all` command.

# Build

    ./Build.sh [name]
    
where name can be either `jamoma`, `iscore` or `iscore-recast`. More to be added.

The script makes some folders like `i-score` and `Jamoma` which are clones of git repositories.
To build a particular version, checkout the version you need in the corresponding folder.
Then run `make` in the `build/[project_folder]`.
For example to build i-score from the top of the `release/0.2` branch :

~~~~
cd i-score
git fetch --all # if you didn't run ./Build.sh with --fetch-all option
git checkout release/0.2 # to switch to the branch
git pull origin release/0.2 # to update the branch with latest repo changes
cd ../build/i-score
make
~~~~
    
## Old setup (Mac OS X only, doesn't require brew / macports)
Follow this if you already have some parts of the OSSIA project on your computer.

If you already have a Jamoma / Score installed using the Ruby scripts : 

    ./Build.sh iscore --clone --classic --install-deps

Or if you already have Jamoma but not Score

    ./Build.sh jamoma iscore --clone --classic --install-deps --jamoma-path=/Path/To/Jamoma/Core/folder
    

# Additional notes
## Packages
For Linux, Jamoma is packed either on a Debian package for Debian, Ubuntu or RPM for Fedora and installed, so it might ask your root password.
On OS X, due to the lack of package manager, make install is called. However, a recipe for Macports is provided on https://github.com/ChristianFrisson/MacPortsCycles

## Installing brew on Mac OS X
To install brew, run in a terminal : 

    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

## Missing packages on ubuntu 13.10
In this case, the following packages must be installed manually from the Trusty archive in this order: 

    http://packages.ubuntu.com/trusty/libmpfr4
    http://packages.ubuntu.com/trusty/libmpfr-dev
    http://packages.ubuntu.com/trusty/libgecode36
    http://packages.ubuntu.com/trusty/libgecodegist36
    http://packages.ubuntu.com/trusty/libgecodeflatzinc36
    http://packages.ubuntu.com/trusty/libgecode-dev

## Raspberry Pi setup
From a new Raspbian installation, run the following command line to install needed package :
`sudo apt-get update && sudo apt-get install -y cmake libxml2-dev libgecode-dev`

