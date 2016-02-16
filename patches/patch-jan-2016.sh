#!/bin/bash
# -----------------------------------------------------------------------------------------------------------
# 
# Steps for script to deploy a TraIT patch for the logging of audit-logs of subjects, upgrade of tomcat
# to version 7.0.67.
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

#
# Don't forget to remove this line when the script is finished.
#
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
# Step 1: installation of Tomcat
#


cd
wget http://apache.cs.uu.nl/tomcat/tomcat-7/v7.0.67/bin/apache-tomcat-7.0.67.tar.gz
# verify the sha1 sum of the downlaoded file.
CHECKSUM_OK=`echo "1bcf2d334c817153d0f46565389e12f36c79ae74 *apache-tomcat-7.0.67.tar.gz" | sha1sum -c - |  awk '{print $NF}'`
if [ $CHECKSUM_OK  != "OK" ]; then
  echo "Problem in SHA1 checksum of downloaded file. Aborting"
  exit 13;
fi

tar -xf apache-tomcat-7.0.67.tar.gz
rm apache-tomcat-7.0.67.tar.gz
cd apache-tomcat-7.0.67

cp -rp ../tomcat/webapps/* ./webapps
cp -rp ../tomcat/openclinica.config .
cp -rp ../tomcat/openclinica.data .
cp -rp ../tomcat/openclinica-ws.config .
cp -rp ../tomcat/openclinica-ws.data .

cp -p ../tomcat/conf/server.xml ./conf
cp -p ../tomcat/conf/context.xml ./conf

#
# Change the symbolic link 
#
cd ~
ln -sfn apache-tomcat-7.0.67 tomcat
cd tomcat
#
# Check the version in the RELEASE-NOTE and symbolic link
#
TOMCAT_VERSION=`cat RELEASE-NOTES | grep "Apache Tomcat Version" | awk '{print $NF}'`
if [ $TOMCAT_VERSION  != "7.0.67" ]; then
  echo "Wrong Tomcat version. Aborting"
  exit 12;
fi

#
# change back to the directory containing this script and the patched war-files
cd 
cd patch-jan-2016

#
# The final step: copy the patched WAR files to the webapp dir
#
cp -vp ./OpenClinica-3.6-${OC_ENVIRONMENT}.war ~/tomcat/webapps/OpenClinica.war
cp -vp ./OpenClinica-ws-3.6-${OC_ENVIRONMENT}.war ~/tomcat/webapps/OpenClinica-ws.war


echo "Finished installing Tomcat and the patched OpenClinica.war"
echo ""
echo "Please perform the configuration step in the server.xml file which is described in the document 'Draaiboek-Patch-OpenClinica-Jan-2016'"
echo "and restart tomcat with the command ~/tomcat/bin/startup.sh"
