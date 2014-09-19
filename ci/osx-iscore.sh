#!/bin/bash
brew update
brew doctor

git clone https://github.com/OSSIA/OSSIA
cd OSSIA
./Build.sh jamoma iscore --clone --install-deps --multi

