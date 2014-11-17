#!/bin/bash
# This script is intended to update all the sub-repos to build a cutting edge i-score with the latest sources available.
if [ -d Jamoma/Core ]; then
  echo Updating Jamoma/Core
  (cd Jamoma/Core; git pull)
fi
if [ -d Jamoma/Core/Score ]; then
  echo Updating Jamoma/Core/Score
  (cd Jamoma/Core/Score; git pull)
fi
if [ -d i-score ]; then
  echo Updating i-score
  (cd i-score; git pull)
fi
if [ -d i-scoreRecast ]; then
  echo Updating i-scoreRecast
  (cd i-scoreRecast; git pull)
fi

