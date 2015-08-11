#!/bin/bash
# ----------------------------------------------------
# >>> ACCEPTANCE ENVIRONMENT <<<
#
# Bash script to copy the required files for the rebranding of OpenClinica to their correct
# locations under the <TOMCAT_HOME> directory. Only tested for OpenClinica 3.1.2 !!!
#
# The script should only be run after the WARs of Openclinica (the regular 
# and Web-services) have been unpacked and copied under the <TOMCAT_HOME> directory
# This script accepts the <TOMCAT_HOME> the complete path as command-line argument.
#
# E.g. rebrand-oc.sh /data/home/clinica/tomcat
#
# Version history
# 0.01 JR 03-05-2013 Initial version
# 0.02 JR 29-05-2013 added environment subtitution
# 0.03 JR 03-06-2013 split up to separate scripts for each environment and added
#                    specific messages for each environment
# -----------------------------------------------------

TOMCAT_HOME=$1

echo Using Tomcat home : $TOMCAT_HOME 
REGULAR_WAR_NAME="OpenClinica"
WS_WAR_NAME="OpenClinica-ws"


#-- make a backup
BACKUP_FILENAME=backup.tar
tar -cvf $BACKUP_FILENAME $TOMCAT_HOME/webapps/$REGULAR_WAR_NAME/images/Logo.gif
tar -rvf $BACKUP_FILENAME $TOMCAT_HOME/webapps/$REGULAR_WAR_NAME/images/OC_login_logo.png
tar -rvf $BACKUP_FILENAME $TOMCAT_HOME/webapps/$REGULAR_WAR_NAME/WEB-INF/jsp/login/login.jsp

tar -rvf $BACKUP_FILENAME $TOMCAT_HOME/webapps/$WS_WAR_NAME/images/Logo.gif
tar -rvf $BACKUP_FILENAME $TOMCAT_HOME/webapps/$WS_WAR_NAME/images/OC_login_logo.png
tar -rvf $BACKUP_FILENAME $TOMCAT_HOME/webapps/$WS_WAR_NAME/WEB-INF/jsp/login/login.jsp
#---------


sed "s/{{{ENVIRONMENT}}}/>> This is the ACCEPTANCE environment. Do not use for actual clinical trial data entry <</" login-environ-param.jsp > login.jsp

cp  ./Logo.gif	 	$TOMCAT_HOME/webapps/$REGULAR_WAR_NAME/images/
cp  ./OC_login_logo.png	$TOMCAT_HOME/webapps/$REGULAR_WAR_NAME/images/
cp  ./login_BG_new.gif 	$TOMCAT_HOME/webapps/$REGULAR_WAR_NAME/images/
cp  ./TraIT_logo.png   	$TOMCAT_HOME/webapps/$REGULAR_WAR_NAME/images/
cp  ./trait.css        	$TOMCAT_HOME/webapps/$REGULAR_WAR_NAME/includes/
cp  ./login.jsp        	$TOMCAT_HOME/webapps/$REGULAR_WAR_NAME/WEB-INF/jsp/login/

cp  ./Logo.gif         	$TOMCAT_HOME/webapps/$WS_WAR_NAME/images/
cp  ./OC_login_logo.png       $TOMCAT_HOME/webapps/$WS_WAR_NAME/images/
cp  ./login_BG_new.gif 	$TOMCAT_HOME/webapps/$WS_WAR_NAME/images/
cp  ./TraIT_logo.png   	$TOMCAT_HOME/webapps/$WS_WAR_NAME/images/
cp  ./trait.css        	$TOMCAT_HOME/webapps/$WS_WAR_NAME/includes/
cp  ./login.jsp        	$TOMCAT_HOME/webapps/$WS_WAR_NAME/WEB-INF/jsp/login/

