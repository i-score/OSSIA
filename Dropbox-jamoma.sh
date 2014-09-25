#!/bin/bash -x

### Script to automate dropbox deployment on the CI machine ###
###### Build using all the cores ######
ARCH=`uname -m`
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
	DISTRO=$(cat /etc/lsb-release | grep DISTRIB_ID | cut -f2 -d=)
	DISTROVERSION=$(cat /etc/lsb-release | grep DISTRIB_RELEASE | cut -f2 -d=)
elif [[ "$OSTYPE" == "darwin"* ]]; then
	DISTRO="OS X"
	DISTROVERSION=""
fi

FOLDER="~/Dropbox/Iscore/Releases/$DISTRO$DISTROVERSION/$ARCH"

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
	cp Jamomacore-0.6-dev-Linux.deb $FOLDER

elif [[ "$OSTYPE" == "darwin"* ]]; then
	cp JamomaCore-0.6-dev-Darwin.tar.gz $FOLDER
	
fi