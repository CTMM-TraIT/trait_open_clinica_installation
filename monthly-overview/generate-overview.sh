#!/bin/bash
#
#
# Script to generate the month overviews of users, studies and sites of openclinica.nl
#
timestamp=`date -I`
echo "Date is : $timestamp"
psql -c "select distinct ua.last_name, ua.first_name, ua.user_name,ua.email from user_account ua, study_user_role sur where (ua.enabled = true) and (ua.user_name = sur.user_name) and (sur.status_id = 1) order by last_name" -d openclinica > $timestamp-overview_active_users.txt
psql -c "select distinct name from study where parent_study_id is not NULL order by name" -d openclinica > $timestamp-overview_sites.txt
psql -c "select name from study where parent_study_id is NULL order by name" -d openclinica > $timestamp-overview_main_studies.txt


cat $timestamp-overview_sites.txt | tr -d '[:digit:]' | sed -e 's#IKZ##g' | sed -e 's#IKW##g' |sed -e 's#IKR##g' | sed -e 's#IKNO##g' | sed -e 's#IKA##g' |sed -e 's#IKO##g' |sed -e 's#IKMN##g'|sed -e 's#IKL##g' | sed 's/^ *//g' | awk '{ print toupper($0) }' | tr -d "," | tr -d "." | sort |  awk '{ print tolower($0) }' | sed 's/\([a-z]\)\([a-zA-Z0-9]*\)/\u\1\2/g' | uniq -i > $timestamp-overview_sites_ordered.txt


