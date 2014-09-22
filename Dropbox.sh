#!/bin/bash -x

### Script to automate dropbox deployment on the CI machine ###
###### Build using all the cores ######
ARCH=`uname -m`
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
	DISTRO=$(cat /etc/lsb-release | grep DISTRIB_ID | cut -f2 -d=)
	DISTROVERSION=$(cat /etc/lsb-release | grep DISTRIB_RELEASE | cut -f2 -d=)
fi

FOLDER="/Users/OSSIA/Dropbox/Iscore/Releases/$DISTRO$DISTROVERSION/$ARCH"
echo $FOLDER
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
	cp build/jamoma/Jamomacore-0.6-dev.deb $FOLDER
	cp i-score0.2 $FOLDER
	
elif [[ "$OSTYPE" == "darwin"* ]]; then
	cp i-score0.2.zip "/Users/OSSIA/Dropbox/Iscore/Releases/OS X/"
fi
