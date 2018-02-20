#!/bin/bash

# Requires initial remote repo set up.
# Requires alteration of target files code.
# Will take the repo aliases as the command line arguments.
# If -- is present in the place of an alias then it will assume
#that it is being used as a one way input/output update script.
# Examples:
#   ./sync.sh Sigma SigmaGitLab -> pulls updates from GitHub Sigma and pushes to SOC-Sigma GitLab
#   ./sync.sh -- SigmaGitLab -> only pushes server-side updates to SOC-Sigma GitLab
#   ./sync.sh -- -- -> This will be made invalid

#cd /opt/sigma/git_sigma

git init

if [[ "$1" != "--" ]]; then
#Editing required per user case
#///////////
    #touch temp_changes.txt
#///////////

    echo "Input source detected."
    input_alias=$1

    git branch -u "$input_alias"/master             #May not be needed
    git remote update "$input_alias"                #Could do singular remote update

#Editing required per user case
#///////////
#    repo_location=$(pwd)
#    target_files=($(git diff --name-only sigma/master master | egrep "rules/"))
#///////////

    echo "Preparing to update with the Input Repository..."
    git pull "$input_alias" master #|| git diff "$output_alias"/master master | mail -s "Merge Conflict - Solution Required" <email>; exit

#Editing required per user case
#///////////
#    for target in "${target_files[@]}"; do
#        git log -p -1 "$repo_location/$target" >> temp_changes.txt
#    done
#///////////

    git branch --unset-upstream

#    if [ -s temp_changes.txt ]; then
#        #mail -s "<Email Subject Line>" <Email address> < <Email content>
#	    echo "Emails sent to listed individuals."
#    fi

#Editing required per user case
#///////////
#    cat temp_changes.txt >> sigma_changes_archive.txt
#    rm temp_changes.txt
#///////////
fi

if [[ "$2" != "--" ]]; then
    echo "Output source detected."
    output_alias=$2

    git branch -u "$output_alias"/master            #May not be needed
    git remote update "$output_alias"               #Could do singular remote update

    if [[ "$(git rev-parse HEAD)" != "$(git rev-parse $output_alias/master)" ]]; then
        ( git pull "$output_alias" master && git push "$output_alias" master ) #|| git diff "$output_alias"/master master | mail -s "Merge Conflict - Solution Required" <email>
    fi

    git branch --unset-upstream
fi
