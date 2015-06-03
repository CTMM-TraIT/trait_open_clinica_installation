#!/bin/bash
# ---------------------------------------------------------------------------------------------------------
#
# Script to package the custom code changes to OpenClinica for the export logging. The code is
# added to the deployed OpenClinica WAR file; this file is called for example: 
# "OpenClinica-3.3-ExportLogging.war"
# The script requires 2 parameters:
#  1) the directory where the modified OpenClinica code is contained
#  2) the tomcat home directory
# for example '/home/johndoe/workspace-oc/OpenClinica'
# ---------------------------------------------------------------------------------------------------------

CURRENT_DIR=`pwd`
BASE_WAR_FILE_NAME="OpenClinica-3.3";
ORIGINAL_WAR_FILE=$BASE_WAR_FILE_NAME.war;
TARGET_WAR_FILE=$BASE_WAR_FILE_NAME-ExportLogging.war;
PROJECT_BASE_DIR=$1;
TOMCAT_HOME_DIR=$2;

if [ x"${PROJECT_BASE_DIR}" = x ]; then
	echo "OpenClinica source directory not set"
	exit 1
fi

if [ x"${TOMCAT_HOME_DIR}" = x ]; then
	echo "Tomcat home directory not set"
	exit 2
fi

echo "Adding custom TraIT changes for the logging of exports to the WAR: $ORIGINAL_WAR_FILE Adding to: $TARGET_WAR_FILE"; 
echo
echo "Source directory is $PROJECT_BASE_DIR"
echo "Tomcat home directory is $TOMCAT_HOME_DIR" 



# unpack the modified java source files and copy them to the correct location under the OpenClinica source
tar -xvf ExportLogging.tar ./core/src/main/java/org/akaza/openclinica/job/ExportLogger.java ./core/src/main/java/org/akaza/openclinica/job/XsltTransformJob.java ./web/src/main/java/org/akaza/openclinica/control/extract/AccessFileServlet.java ./core/src/main/java/org/akaza/openclinica/domain/rule/action/RuleActionComparator.java

cp ./core/src/main/java/org/akaza/openclinica/job/ExportLogger.java        $PROJECT_BASE_DIR/core/src/main/java/org/akaza/openclinica/job/ExportLogger.java
cp ./core/src/main/java/org/akaza/openclinica/job/XsltTransformJob.java    $PROJECT_BASE_DIR/core/src/main/java/org/akaza/openclinica/job/XsltTransformJob.java
cp ./web/src/main/java/org/akaza/openclinica/control/extract/AccessFileServlet.java  $PROJECT_BASE_DIR/web/src/main/java/org/akaza/openclinica/control/extract/AccessFileServlet.java
cp ./core/src/main/java/org/akaza/openclinica/domain/rule/action/RuleActionComparator.java $PROJECT_BASE_DIR/core/src/main/java/org/akaza/openclinica/domain/rule/action/RuleActionComparator.java
# now build OpenClinica
cd $PROJECT_BASE_DIR
mvn clean install -DskipTests=true
cd $CURRENT_DIR


mkdir ~/package-patches
mkdir -p ~/package-patches/properties/xslt
cp ../logging/logback-test.xml ~/package-patches
cp ../logging/datainfo.properties ~/package-patches
cp ./properties/xslt/*.* ~/package-patches/properties/xslt


cd ~/package-patches
cp $TOMCAT_HOME_DIR/webapps/OpenClinica.war .

CORE_JAR_FILE_NAME=`jar -tvf OpenClinica.war | grep OpenClinica-core | grep jar | awk '{print $8}'`
echo "Core jar file name: $CORE_JAR_FILE_NAME"
jar -xvf OpenClinica.war $CORE_JAR_FILE_NAME

mkdir -p ./org/akaza/openclinica/job/

cp $PROJECT_BASE_DIR/core/target/classes/org/akaza/openclinica/job/ExportLogger.class ./org/akaza/openclinica/job
cp $PROJECT_BASE_DIR/core/target/classes/org/akaza/openclinica/job/XsltTransformJob.class ./org/akaza/openclinica/job
jar -uf $CORE_JAR_FILE_NAME ./org/akaza/openclinica/job/ExportLogger.class
jar -uf $CORE_JAR_FILE_NAME ./org/akaza/openclinica/job/XsltTransformJob.class


mkdir -p ./org/akaza/openclinica/domain/rule/action/
cp $PROJECT_BASE_DIR/core/target/classes/org/akaza/openclinica/domain/rule/action/RuleActionComparator.class ./org/akaza/openclinica/domain/rule/action
jar -uf $CORE_JAR_FILE_NAME ./org/akaza/openclinica/domain/rule/action/RuleActionComparator.class


jar -uf $CORE_JAR_FILE_NAME ./logback-test.xml

jar -uf $CORE_JAR_FILE_NAME ./properties/xslt/odm_to_html.xsl
jar -uf $CORE_JAR_FILE_NAME ./properties/xslt/odm_spss_sps.xsl
jar -uf $CORE_JAR_FILE_NAME ./properties/xslt/odm_spss_dat.xsl
jar -uf $CORE_JAR_FILE_NAME ./properties/xslt/ODMToTAB.xsl


# update the JAR file in the WAR
jar -uf ./OpenClinica.war $CORE_JAR_FILE_NAME

mkdir -p ./WEB-INF/classes/org/akaza/openclinica/control/extract


mv ./datainfo.properties ./WEB-INF/classes
jar -uf OpenClinica.war ./WEB-INF/classes/datainfo.properties

cp $PROJECT_BASE_DIR/web/target/classes/org/akaza/openclinica/control/extract/AccessFileServlet.class ./WEB-INF/classes/org/akaza/openclinica/control/extract/
jar -uf OpenClinica.war ./WEB-INF/classes/org/akaza/openclinica/control/extract/AccessFileServlet.class

# the file name OpenClinica-ExportLogging.war is expected by the deploy-export-logging.sh
mv ./OpenClinica.war ./OpenClinica-Patched.war
rm -rf ./org
rm -rf ./WEB-INF
rm ./logback-test.xml
rm -rf ./properties

echo "Modified OpenClinica WAR file can be found in `pwd ~/package-patches`"


cd $CURRENT_DIR
cp ./deploy-patches.sh ~/package-patches

echo "Cleaning up"


rm -rf ./core/
rm -rf ./web/
echo "Finished"

