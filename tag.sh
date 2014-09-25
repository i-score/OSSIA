#!/bin/bash

rm tag
echo "====== Jamoma/Core ======" >> tag
(cd Jamoma/Core; git branch|grep \*) >> tag
(cd Jamoma/Core; git log -1) >> tag

echo >> tag
echo "====== OSSIA/Score ======" >> tag
(cd Jamoma/Core/Score; git branch|grep \*) >> tag
(cd Jamoma/Core/Score; git log -1) >> tag

echo >> tag
echo "====== i-score/i-score ======" >> tag
(cd i-score; git branch|grep \*) >> tag
(cd i-score; git log -1) >> tag