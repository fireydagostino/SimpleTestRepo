#!/bin/bash

#TO DO:
#   1) Fix sync check for matched repositories - multiple branches/subtree branch
#       1.1) Ignore sigma sync check and pull everyday.
#       1.2) Keep GitLab sync check
#   2) Pull / Push between KIBANA server and Gitlab
#   3) Construct merge conflict email if present
#   4) Update SOC-Script Documentation page

#Will need to do: git branch syncro prior to running script for first time

cd /opt/sigma/git_sigma

touch temp_changes.txt

#Add: git checkout syncro //////////////////////

git init

git branch -u sigma/master

git remote update sigma

repo_location=$(pwd)
target_files=($(git diff --name-only sigma/master master | egrep "rules/"))
            #Change above to sigma/master syncro //////////////////////////////////

#local_repo="$(git rev-parse HEAD)"             /////////perform in syncro -- can remove
#remote_repo="$(git rev-parse sigma/master)"    /////////perform in syncro -- can remove

#if [[ "$local_repo" == "$remote_repo" ]]; then /////////perform in syncro -- replace variables
#    echo "The two repositories are matched."   /////////perform in syncro    with commands
                                #Add: git checkout master
                                #Add: skip to gitlab pull/push part
#else                                           /////////perform in syncro
#    echo "The local and remote repositories are not synced up."    /////////perform in syncro
sync=true
#fi                                             /////////perform in syncro

if [ "$sync" = true ]; then #remove this condition and place all cmds inside above else/////////
    echo "Preparing to sync up repositories..."
    git pull sigma master                       #change to: git pull sigma syncro
    #Add: git branch --unset-upstream
    #Add: git checkout master
    #Add: git merge syncro
fi

for target in "${target_files[@]}"; do
        git log -p -1 "$repo_location/$target" >> temp_changes.txt
done

git branch --unset-upstream                     #remove - done earlier

if [ -s temp_changes.txt ]; then
    #mail -s "<Email Subject Line>" <Email address> < <Email content>
	echo "Emails sent to listed individuals."
fi

cat temp_changes.txt >> sigma_changes_archive.txt
rm temp_changes.txt


#Add the following: ///////////Incorporate merge conflict resolution here
#if [[ "$(git rev-parse HEAD)" != "$(git rev-parse origin/master)" ]]; then
#   ( git pull origin master && git push origin master ) || git diff origin/master master | mail -s "Merge Conflict - Solution Required" anthony.dagostino@bell.ca
#fi
