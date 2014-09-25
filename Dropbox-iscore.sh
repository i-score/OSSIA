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

FOLDER="$HOME/Dropbox/Iscore/Releases/$DISTRO$DISTROVERSION/$ARCH"
mkdir -p "$FOLDER"

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
	tar -cJf i-score0.2.tar.xz i-score0.2
	cp i-score0.2.tar.xz "$FOLDER"
	
elif [[ "$OSTYPE" == "darwin"* ]]; then
	zip -r i-score0.2.zip i-score0.2.app
	cp i-score0.2.zip "$FOLDER"

fi

./tag.sh
cp tag "$FOLDER"/tag.txt
