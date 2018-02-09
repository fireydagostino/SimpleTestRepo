#!/bin/bash

git remote update

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
    git pull origin master
fi