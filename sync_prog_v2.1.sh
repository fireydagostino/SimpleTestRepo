#!/bin/bash


# Author: Anthony D'Agostino

# Secondary script to perform Sigma updates between Neo23x0's Sigma files on GitHub and
#the files located on the KIBANA server, which are then synchronized with the
#SOC-GitLab files, if neccessary.
# All new rule commits are emailed to the respective individuals.
# All potential merge conflicts betweens the KIBANA server files and the files on
#SOC-Gitlab are emailed to the respective individuals.

timestamp(){
	date
}

cd /opt/sigma/git_sigma

touch temp_changes.txt

git init
git branch -u sigma/master
git remote update sigma

repo_location=$(pwd)
target_files=($(git diff --name-only sigma/master master | egrep "rules/"))

printf "\nPreparing to update with the Neo-Sigma Repository...\n\n"
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

git commit sigma_changes_archive.txt -m "Sigma Rule Changes Archive updated."

# Please note that the script will not attempt to complete any Merge Conflicts
#between the KIBANA server and the SOC-GitLab. Instead emails will be sent out
#to the designated individuals with information regarding the merge conflicts.
#As a result, the individuals must resolve the conflicts and then manually
#update the appropriate environment (ie push/pull).
printf "\n\nChecking update requirements with SOC-GitLab...\n"
if [[ "$(git rev-parse HEAD)" != "$(git rev-parse origin/master)" ]]; then
	printf "Update Acknowledged. Preparing to update with SOC-GitLab...\n\n"
	( git pull origin master && git push origin master ) || git diff origin/master master | mail -s "Merge Conflict - Solution Required" anthony.dagostino@bell.ca
else
	echo "SOC-GitLab update is not required. Ending Script..."
fi

cd /opt/sigma/elastic_rules/rule_templates
echo "Now inside: $(pwd)"

#a_rule="rules/application/appframework_django_exceptions.yml"
description=$(cat /opt/sigma/git_sigma/rules/application/appframework_django_exceptions.yml | egrep "description.*")
echo "Decription found: $description"
name="$RANDOM****$(timestamp)****"
echo "Name found: $name"
kibana_string="$(python3.4 /opt/sigma/git_sigma/tools/sigmac /opt/sigma/git_sigma/rules/application/appframework_django_exceptions.yml)"
echo "Kibana String found: $kibana_string"

sed -n "s/<name>/$name/" /opt/sigma/elastic_rules/rule_templates/any_match_template.yaml
sed -n "s/<description/$description/" /opt/sigma/elastic_rules/rule_templates/any_match_template.yaml
sed -n "s/<kibana_string>/$kibana_string/" /opt/sigma/elastic_rules/rule_templates/any_match_template.yaml

#printf "\nLocation: %s \nKIBANA Script: %s\n" "$a_rule" "$(python3.4 /opt/sigma/git_sigma/tools/sigmac /opt/sigma/git_sigma/rules/application/appframework_django_exceptions.yml)" >> kibana_rule_strings.txt

#printf "%s\t%s\n"

#python3.4 /opt/sigma/git_sigma/tools/sigmac /opt/sigma/git_sigma/rules/application/appframework_django_exceptions.yml >> kibana_rule_strings.txt
#git remote -v

#for rules in "${target_files[@]}"; do
#
#done

