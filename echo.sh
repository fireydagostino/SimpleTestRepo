#!/bin/bash

ls .
echo Hello World
echo pwd:
pwd

mkdir newdirect

cd newdirect
pwd

cd ..
pwd

rm -vr newdirect
ls .

git status
git branch experimental
git branch
git checkout experimental
git status
git checkout master
git branch -d experimental
git branch

git remote update

git rev-parse @ > hash_list.txt
git rev-parse @{u} >> hash_list.txt
cat hash_list.txt
rm hash_list.txt

local_repo=$(git rev-parse @)
remote_repo="$(git rev-parse @{u})"

if [[ "$local_repo" == "$remote_repo" ]]; then
    echo "The two repositories are matched"
else
    echo "The local and remote repositories are not synced up."
    sync=true
fi

if [ "$sync" = true ]; then
    echo "Preparing to sync up repositories..."
fi
