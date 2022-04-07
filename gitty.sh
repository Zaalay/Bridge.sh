#! /usr/bin/env bash
#
# Clean ignored files
#

git clean -d -f -X
git add .

! command -v beautysh && sudo pip install beautysh
beautysh -i 2 -s paronly *.sh

git add .
git commit -am "${1}"
git push

echo "DONE!"
