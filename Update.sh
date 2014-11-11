#!/bin/bash
# This script is intended to update all the sub-repos to build a cutting edge i-score with the latest sources available.
(cd Jamoma/Core; git pull)
(cd Jamoma/Core/Score; git pull)
(cd i-score; git pull)
(cd i-scoreRecast; git pull)

