#!/bin/bash
# 
# Steps for script to incoorporate the export logging in OC:
# ---------------------------------------------------------------------------------------------------------
#- make a backup of the current WAR file
#- replace the class XsltTransformJob.class and add ExportLogger.class to the WAR
#- make a backup of the datainfo.properties
#- clear the work directory
#- clear the unpacked WAR directory
#- place the newly modified WAR in the webapps dir
#- start OC
#- wait for startup
#- stop OC
#- restore the datainfo.properties file
#- start OC
# -----------------------------------------------------------------------------------------------------------
echo 'Starting deployment of the TraIT OpenClinica export logging patch'
TOMCAT_RUNNING=`ps -ef | grep java | grep tomcat`
if [ -n "${TOMCAT_RUNNING}" ]; then
	echo "Tomcat is running. Please stop Tomcat manually (with <TOMCAT_HOME>/bin/shutdown.sh)"
	exit 10
fi

mkdir ~/backup-export-logging
cp  ~/tomcat/webapps/OpenClinica.war ~/backup-export-logging
cp ~/tomcat/webapps/OpenClinica/WEB-INF/classes/datainfo.properties ~/backup-export-logging
rm -rf ~/tomcat/webapps/OpenClinica
# rm -rf ~/tomcat/work/Catalina/localhost/OpenClinica

jar xf OpenClinica-Patched.war WEB-INF/classes/datainfo.properties
mv WEB-INF/classes/datainfo.properties ./datainfo-modified.properties
tail -n8 datainfo-modified.properties >> ~/backup-export-logging/datainfo.properties


cp ./OpenClinica-Patched.war ~/tomcat/webapps/OpenClinica.war
cd ~/tomcat/logs
echo 'Starting up OpenClinica - script will wait 2 minutes and then proceed'
../bin/startup.sh
sleep 120
echo 'Shutting down OpenClinica - script will wait 2 minutes and then proceed'
../bin/shutdown.sh
sleep 120
cp ~/backup-export-logging/datainfo.properties ~/tomcat/webapps/OpenClinica/WEB-INF/classes/

rm -rf ./WEB-INF/
echo 'Finished, please startup Tomcat'



