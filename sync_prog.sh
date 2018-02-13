#!/bin/bash

touch temp_changes.txt

git branch -u sigma/master

git remote update sigma

repo_location=$(pwd)
target_files=($(git diff --name-only sigma/master master | egrep "rules/"))


#local_repo=$(git rev-parse HEAD)
#remote_repo="$(git rev-parse sigma/master)"

#if [[ "$local_repo" == "$remote_repo" ]]; then
#    echo "The two repositories are matched."
#else
#    echo "The local and remote repositories are not synced up."
sync=true
#fi

if [ "$sync" = true ]; then
    echo "Preparing to sync up repositories..."
    git pull sigma master
fi

for target in "${target_files[@]}"; do
        git log -p -1 "$repo_location/$target" >> temp_changes.txt
done

git branch --unset-upstream

if [ -s temp_changes.txt ]; then
    #add mail command here
	echo "Emails sent to listed individuals."
fi

cat temp_changes.txt >> sigma_changes_archive.txt
rm temp_changes.txt
