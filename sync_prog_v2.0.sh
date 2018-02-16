#!/bin/bash

#TO DO:
#   - Update SOC-Script Documentation page

#Will need to do: git branch syncro prior to running script for first time

cd /opt/sigma/git_sigma

touch temp_changes.txt

git checkout syncro
git init

git branch -u sigma/master
git remote update sigma

repo_location=$(pwd)
target_files=($(git diff --name-only sigma/master syncro | egrep "rules/"))

if [[ "$(git rev-parse HEAD)"  == "$(git rev-parse sigma/master)" ]]; then
    echo "The two repositories are matched."
    git checkout master
else
    echo "The local and remote repositories are not synced up."
    echo "Preparing to sync up repositories..."
    git pull sigma syncro
    git branch --unset-upstream
    git checkout master
    git merge syncro
fi

for target in "${target_files[@]}"; do
        git log -p -1 "$repo_location/$target" >> temp_changes.txt
done

if [ -s temp_changes.txt ]; then
    #mail -s "<Email Subject Line>" <Email address> < <Email content>
	echo "Emails sent to listed individuals."
fi

cat temp_changes.txt >> sigma_changes_archive.txt
rm temp_changes.txt

git branch -u origin/master
if [[ "$(git rev-parse HEAD)" != "$(git rev-parse origin/master)" ]]; then
   ( git pull origin master && git push origin master ) || git diff origin/master master | mail -s "Merge Conflict - Solution Required" <recipient's email>
fi
git branch --unset-upstream
