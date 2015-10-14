#!/bin/bash
# -----------------------------------------------------------------------------------------------------------
# 
# Steps for script to deploy OC version 3.6 with the patch for TraIT1509 330 / OC6757
#
# -----------------------------------------------------------------------------------------------------------
echo 'Starting deployment of the TraIT OpenClinica version 3.6, TraIT patch for TraIT1509 330'

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
		echo $'\n\nUsage: deploy-oc3.6-patch [ENVIRONMENT] \nwhere ENVIRONMENT is either PROD, ACCEPTANCE, SANDBOX or ARCHIVE';
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
# clean up the previous webapps and work directories
#
rm -rf ~/tomcat/webapps/OpenClinica
rm -rf ~/tomcat/work/Catalina/localhost/OpenClinica
rm -rf ~/tomcat/webapps/OpenClinica-ws
rm -rf ~/tomcat/work/Catalina/localhost/OpenClinica-ws



cp -v ./OpenClinica-3.6-${OC_ENVIRONMENT}.war ~/tomcat/webapps/OpenClinica.war
cp -v ./OpenClinica-ws-3.6-${OC_ENVIRONMENT}.war ~/tomcat/webapps/OpenClinica-ws.war




echo "Finished, please startup Tomcat, as user 'clinica'. Use the command <HOME_DIR_USER_CLINICA>/tomcat/bin/startup"

