#!/bin/bash


# Author: Anthony D'Agostino

# Secondary script to perform Sigma updates between Neo23x0's Sigma files on GitHub and
#the files located on the KIBANA server, which are then synchronized with the
#SOC-Sigma GitLab files, if neccessary.
# All new rule commits are emailed to the respective individuals.
# All potential merge conflicts betweens the KIBANA server files and the files on
#SOC-Sigma Gitlab are emailed to the respective individuals.
# Update: Will now convert sigma rules into their respective ElastAlert rules through
#the any_match_template.yaml file. The newly converted files will then be uploaded
#onto the SOC-Elastalert GitLab for further review by a Rule-Admin.
# Note: There are two separately initialized git repository that are used by this
#script. The first is in /opt/sigma/git_sigma which deals with the Sigma rule
#retrieval portion as well as the SOC-Sigma Gitlab upload. The second is in
#/opt/sigma/elastic_rules and deals with updating the SOC-Elastalert GitLab of
#any newly generated rules. These newly generated rules will  be placed inside
#of the autobot-rules branch.

cd /opt/sigma/git_sigma

touch temp_changes.txt

git init
git branch -u sigma/master
git remote update sigma

repo_location=$(pwd)
target_files=($(git diff --name-status --diff-filter=r master sigma/master | egrep "rules/" | cut -d $'\t' -f 2))
renamed_files=($(git diff --name-status --diff-filter=R master sigma/master | egrep "rules/" | egrep "R100" | cut -d $'\t' -f 3))
changed_and_renamed_files=($(git diff --name-status --diff-filter=R master sigma/master | egrep "rules/" | egrep -v "R100" | cut -d $'\t' -f 3))

printf "\nPreparing to update with the Neo-Sigma Repository...\n\n"
git pull sigma master

if [[ "${target_files[0]}" != "" ]]; then
	printf "# # # # FILES CHANGED (NO RENAMES) # # # #\n" >> temp_changes.txt
fi
for target in "${target_files[@]}"; do
	git log -p -1 "$repo_location/$target" >> temp_changes.txt
done

if [[ "${changed_and_renamed_files[0]}" != "" ]]; then
	printf "\n# # # # FILES CHANGED AND RENAMED # # # #\n" >> temp_changes.txt
fi
for target in "${changed_and_renamed_files[@]}"; do
	git log -p -1 "$repo_location/$target" >> temp_changes.txt
done

if [[ "${renamed_files[0]}" != "" ]]; then
	printf "\n# # # # FILES RENAMED (NO OTHER CHANGES) # # # #\n" >> temp_changes.txt
fi
for target in "${renamed_files[@]}"; do
	git log -p -1 "$repo_location/$target" >> temp_changes.txt
done

git branch --unset-upstream

if [ -s temp_changes.txt ]; then
	( mail -s "Sigma Rules Update" anthony.dagostino@bell.ca < /opt/sigma/git_sigma/temp_changes.txt && mail -s "Sigma Rules Update" jonathan.mallette@bell.ca < /opt/sigma/git_sigma/temp_changes.txt && echo "Emails sent to listed individuals." ) || echo "Error in sending emails."
	printf "\n\n*=*=*=*=* DATE UPDATED: $(date) *=*=*=*=*\n\n" >> sigma_changes_archive.txt
	cat temp_changes.txt >> sigma_changes_archive.txt
fi

git commit sigma_changes_archive.txt -m "Sigma Rule Changes Archive updated."

# Please note that the script will not attempt to complete any Merge Conflicts
#between the KIBANA server and the SOC-Sigma GitLab. Instead emails will be sent out
#to the designated individuals with information regarding the merge conflicts.
#As a result, the individuals must resolve the conflicts and then manually
#update the appropriate environment (ie push/pull).
printf "\nChecking update requirements with SOC-GitLab...\n"
if [[ "$(git rev-parse HEAD)" != "$(git rev-parse origin/master)" ]]; then
	printf "Update Acknowledged. Preparing to update with SOC-GitLab...\n\n"
	( git pull origin master && git push origin master ) || ( git diff master origin/master | mail -s "Merge Conflict - Solution Required" anthony.dagostino@bell.ca )
else
	echo "SOC-GitLab update is not required."
fi




cd /opt/sigma/elastic_rules

printf "\nUpdating Remote Repository for SOC-Elastalert GitLab...\n"
git remote update elastic

#description="$(cat /opt/sigma/git_sigma/rules/application/appframework_django_exceptions.yml | egrep "description.*" | cut -d " " -f 2- )"
#name="$RANDOM""_auto_generated_rule_""$RANDOM"
#kibana_string="$(python3.4 /opt/sigma/git_sigma/tools/sigmac /opt/sigma/git_sigma/rules/application/appframework_django_exceptions.yml)"
#cp /opt/sigma/elastic_rules/rule_templates/any_match_template.yaml "$name"
#sed -i "s/<name>/$name/" /opt/sigma/elastic_rules/"$name"
#sed -i "s/<description>/$description/" /opt/sigma/elastic_rules/"$name"
#sed -i "s/<kibana_string>/$kibana_string/" /opt/sigma/elastic_rules/"$name"

if [ -s temp_changes.txt ]; then
	printf "\nPreparing to update newly changed rules to the Elastalert format...\n"
	for rule in "${target_files[@]}"; do
		description="$(cat /opt/sigma/git_sigma/$rule | egrep "description.*" | cut -d " " -f 2- )"
		name="$RANDOM""_auto_generated_rule_""$RANDOM"
		kibana_string="$(python3.4 /opt/sigma/git_sigma/tools/sigmac /opt/sigma/git_sigma/$rule)"

		cp /opt/sigma/elastic_rules/rule_templates/any_match_template.yaml "$name"

		sed -i "s/<name>/$name/" /opt/sigma/elastic_rules/"$name"
		sed -i "s/<description>/$description/" /opt/sigma/elastic_rules/"$name"
		sed -i "s/<kibana_string>/$kibana_string/" /opt/sigma/elastic_rules/"$name"
	done
	printf "\nUpdates complete. Please find auto-generated files in /opt/sigma/elastic_rules.\n"
fi

printf "\nUpdating between SOC-Elastalert Gitlab and KIBANA Server...\n\n"
( git pull elastic autobot-rules && git push elastic autobot-rules && echo "Update Success.") || echo "SOC-Elastalert GitLab sync failure."

cd /opt/sigma/git_sigma
rm temp_changes.txt

