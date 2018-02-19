#!/bin/bash

#TO DO:
#   1) Update SOC-Script Documentation page

cd /opt/sigma/git_sigma

touch temp_changes.txt

git init
git branch -u sigma/master
git remote update sigma

repo_location=$(pwd)
target_files=($(git diff --name-only sigma/master master | egrep "rules/"))

echo "Preparing to update with the Neo-Sigma Repository..."
git pull sigma master

for target in "${target_files[@]}"; do
	git log -p -1 "$repo_location/$target" >> temp_changes.txt
done

git branch --unset-upstream

if [ -s temp_changes.txt ]; then
	mail -s "Sigma Rules Update" anthony.dagostino@bell.ca < /opt/sigma/git_sigma/temp_changes.txt
	mail -s "Sigma Rules Update" jonathan.mallette@bell.ca < /opt/sigma/git_sigma/temp_changes.txt
	echo "Emails sent to listed individuals."
fi

cat temp_changes.txt >> sigma_changes_archive.txt
rm temp_changes.txt


if [[ "$(git rev-parse HEAD)" != "$(git rev-parse origin/master)" ]]; then
	( git pull origin master && git push origin master ) || git diff origin/master master | mail -s "Merge Conflict - Solution Required" anthony.dagostino@bell.ca
fi
