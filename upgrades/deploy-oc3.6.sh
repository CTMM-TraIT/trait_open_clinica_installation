#!/bin/bash
# -----------------------------------------------------------------------------------------------------------
# 
# Steps for script to deploy OC version 3.6 for the upgrade from 3.3
#
# -----------------------------------------------------------------------------------------------------------
echo 'Starting deployment of the TraIT OpenClinica version 3.6'
BACKUP_DIR='backup_openclinica_v33'
CURRENT_DIR=`pwd`

OC_ENVIRONMENT='';
case $1 in 
	'PROD') 
		OC_ENVIRONMENT='PROD';;
	'ACCEPTANCE') 
		OC_ENVIRONMENT='ACCEPTANCE';;
        'SANDBOX') 
		OC_ENVIRONMENT='SANDBOX';;
	'ARCHIVE') 
		OC_ENVIRONMENT='ARCHIVE';;
	'DEV' ) 
		OC_ENVIRONMENT='DEV';;
	*)
		echo $'\nInvalid environment: '$1'.'
		echo $'\n\nUsage: deploy-oc3.6 [ENVIRONMENT] \nwhere ENVIRONMENT is either PROD, ACCEPTANCE, SANDBOX or ARCHIVE';
		exit 21;;
esac
echo "Running in environment $OC_ENVIRONMENT"


USER_NAME=`whoami`;

if [ $USER_NAME  != "clinica" ]; then
  echo "Script must be run as user 'clinica'. Aborting"
  exit 11;
fi


TOMCAT_RUNNING=`ps -ef | grep java | grep tomcat`
if [ -n "${TOMCAT_RUNNING}" ]; then
	echo "Tomcat is running. Please stop Tomcat manually (with <TOMCAT_HOME>/bin/shutdown.sh)"
	exit 10
fi


#
# Make backups of the datainfo.properties files.
#
echo "Creating backup directory $BACKUP_DIR and backing-up datainfo.properties of OpenClinica and OpenClinica-ws"
cd ~
mkdir -p $BACKUP_DIR
BACKUP_DIR=~/$BACKUP_DIR
cd $CURRENT_DIR

cp -v ~/tomcat/webapps/OpenClinica.war $BACKUP_DIR
cp -v ~/tomcat/webapps/OpenClinica/WEB-INF/classes/datainfo.properties $BACKUP_DIR/datainfo.properties

cp -v ~/tomcat/webapps/OpenClinica-ws.war $BACKUP_DIR
cp -v ~/tomcat/webapps/OpenClinica-ws/WEB-INF/classes/datainfo.properties $BACKUP_DIR/datainfo-ws.properties


#
# clean up the previous webapps and work directories
#
rm -rf ~/tomcat/webapps/OpenClinica
rm -rf ~/tomcat/work/Catalina/localhost/OpenClinica
rm -rf ~/tomcat/webapps/OpenClinica-ws
rm -rf ~/tomcat/work/Catalina/localhost/OpenClinica-ws



cp -v ./OpenClinica-3.6-${OC_ENVIRONMENT}.war ~/tomcat/webapps/OpenClinica.war
cp -v ./OpenClinica-ws-3.6-${OC_ENVIRONMENT}.war ~/tomcat/webapps/OpenClinica-ws.war

cd ~/tomcat/logs
echo 'Starting up OpenClinica - script will wait 1 minute and then proceed'
../bin/startup.sh
sleep 60
echo 'Shutting down OpenClinica - script will wait 1 minute and then proceed'
../bin/shutdown.sh
sleep 60

cp -v $BACKUP_DIR/datainfo.properties ~/tomcat/openclinica.config/datainfo.properties
cp -v $BACKUP_DIR/datainfo-ws.properties ~/tomcat/openclinica-ws.config/datainfo.properties
cp -v $BACKUP_DIR/datainfo.properties ~/tomcat/webapps/OpenClinica/WEB-INF/classes/datainfo.properties
cp -v $BACKUP_DIR/datainfo-ws.properties ~/tomcat/webapps/OpenClinica-ws/WEB-INF/classes/datainfo.properties


rm -rf ./WEB-INF/


echo 'Finished, please startup Tomcat'

