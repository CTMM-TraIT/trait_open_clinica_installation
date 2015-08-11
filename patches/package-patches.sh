#!/bin/bash
# ---------------------------------------------------------------------------------------------------------
#
# Script to package the custom code changes to OpenClinica for the export logging. The code is
# added to the OpenClinica and OpenClinica-ws WAR files
# The script requires 2 parameters:
#  1) the directory where the modified OpenClinica code is contained
#  2) the tomcat home directory
# for example '/home/johndoe/workspace-oc/OpenClinica'
# ---------------------------------------------------------------------------------------------------------

CURRENT_DIR=`pwd`
BASE_WAR_FILE_NAME="OpenClinica.war";
BASE_WS_WAR_FILE_NAME="OpenClinica-ws.war";
PATH_TO_ORIGINAL_WAR=~/oc-3.6/OpenClinica-3.6/distribution/OpenClinica.war
PATH_TO_ORIGINAL_WS_WAR=~/oc-3.6/OpenClinica-ws-3.6/distribution/OpenClinica-ws.war
ORIGINAL_WAR_FILE=$BASE_WAR_FILE_NAME.war;
TARGET_WAR_FILE=$BASE_WAR_FILE_NAME-ExportLogging.war;
PROJECT_BASE_DIR=$1;


if [ x"${PROJECT_BASE_DIR}" = x ]; then
	echo "OpenClinica source directory not set"
	exit 1
fi

echo "Adding custom TraIT changes for the logging of exports to the WAR: $ORIGINAL_WAR_FILE Adding to: $TARGET_WAR_FILE"; 
echo
echo "Source directory is $PROJECT_BASE_DIR"
 



# unpack the modified java source files and copy them to the correct location under the OpenClinica source
tar -xvf ExportLogging.tar ./core/src/main/java/org/akaza/openclinica/job/ExportLogger.java ./core/src/main/java/org/akaza/openclinica/job/XsltTransformJob.java ./web/src/main/java/org/akaza/openclinica/control/extract/AccessFileServlet.java ./core/src/main/java/org/akaza/openclinica/domain/rule/action/RuleActionComparator.java

cp ./core/src/main/java/org/akaza/openclinica/job/ExportLogger.java        $PROJECT_BASE_DIR/core/src/main/java/org/akaza/openclinica/job/ExportLogger.java
cp ./core/src/main/java/org/akaza/openclinica/job/XsltTransformJob.java    $PROJECT_BASE_DIR/core/src/main/java/org/akaza/openclinica/job/XsltTransformJob.java
cp ./web/src/main/java/org/akaza/openclinica/control/extract/AccessFileServlet.java  $PROJECT_BASE_DIR/web/src/main/java/org/akaza/openclinica/control/extract/AccessFileServlet.java
cp ./core/src/main/java/org/akaza/openclinica/domain/rule/action/RuleActionComparator.java $PROJECT_BASE_DIR/core/src/main/java/org/akaza/openclinica/domain/rule/action/RuleActionComparator.java

cp ../rebranding/trait.css 		$PROJECT_BASE_DIR/web/src/main/webapp/includes/trait.css
cp ../rebranding/Logo.gif	 	$PROJECT_BASE_DIR/web/src/main/webapp/images/Logo.gif
cp ../rebranding/OC_login_logo.png	$PROJECT_BASE_DIR/web/src/main/webapp/images/OC_login_logo.png
cp ../rebranding/login_BG_new.gif 	$PROJECT_BASE_DIR/web/src/main/webapp/images/login_BG_new.gif
cp ../rebranding/TraIT_logo.png   	$PROJECT_BASE_DIR/web/src/main/webapp/images/TraIT_logo.png

#
# now build OpenClinica. We do not use the WAR's produced by this step; it is only a check to see if the interfaces of the  modified files still works.
#
cd $PROJECT_BASE_DIR
mvn clean install -DskipTests=true
cd $CURRENT_DIR

mkdir -p ~/package-patches
mkdir -p ~/package-patches/properties/xslt
mkdir -p ~/package-patches/includes
mkdir -p ~/package-patches/images
cp ../logging/logback-test.xml ~/package-patches
cp ../logging/datainfo.properties ~/package-patches
cp ./properties/xslt/*.* ~/package-patches/properties/xslt

cp ../rebranding/trait.css 		~/package-patches/includes/trait.css
cp ../rebranding/Logo.gif	 	~/package-patches/images/Logo.gif
cp ../rebranding/OC_login_logo.png	~/package-patches/images/OC_login_logo.png
cp ../rebranding/login_BG_new.gif 	~/package-patches/images/login_BG_new.gif
cp ../rebranding/TraIT_logo.png   	~/package-patches/images/TraIT_logo.png

cp ../rebranding/login-environ-param.jsp ~/package-patches

#
# Copy the 2 original war file we are going to work with
#
cd ~/package-patches
cp $PATH_TO_ORIGINAL_WAR .
cp $PATH_TO_ORIGINAL_WS_WAR .

CORE_JAR_FILE_NAME=`jar -tvf OpenClinica.war | grep OpenClinica-core | grep jar | awk '{print $8}'`
echo "Core jar file name: $CORE_JAR_FILE_NAME"
jar -xvf OpenClinica.war $CORE_JAR_FILE_NAME
# mv $CORE_JAR_FILE_NAME $CORE_JAR_FILE_NAME.web

#
# check if the core-jar are the same in both the OpenClinica and OpenClinica-ws wars.
#
#jar -xvf OpenClinica-ws.war $CORE_JAR_FILE_NAME
#DIFFERENCE=`diff $CORE_JAR_FILE_NAME $CORE_JAR_FILE_NAME.web`

#if [ x"${DIFFERENCE}" != x ]; then
#	echo "Difference found in the $CORE_JAR_FILE_NAME between OpenClinica.war and OpenClinca-ws.war"
#	exit 999
#fi
#echo "Difference : ${DIFFERENCE}"
#exit 888


#
# First of all update the images and logo files in the WARS
#
echo "Rebranding logo's and images ..."

jar -uf ./OpenClinica.war ./includes/trait.css
jar -uf ./OpenClinica-ws.war ./includes/trait.css

jar -uf ./OpenClinica.war ./images/Logo.gif
jar -uf ./OpenClinica-ws.war ./images/Logo.gif

jar -uf ./OpenClinica.war ./images/OC_login_logo.png
jar -uf ./OpenClinica-ws.war ./images/OC_login_logo.png

jar -uf ./OpenClinica.war ./images/login_BG_new.gif
jar -uf ./OpenClinica-ws.war ./images/login_BG_new.gif

jar -uf ./OpenClinica.war ./images/TraIT_logo.png
jar -uf ./OpenClinica-ws.war ./images/TraIT_logo.png

echo "Done rebranding"

mkdir -p ./org/akaza/openclinica/job/

echo "Adding export logging patch ..."
cp $PROJECT_BASE_DIR/core/target/classes/org/akaza/openclinica/job/ExportLogger.class ./org/akaza/openclinica/job
cp $PROJECT_BASE_DIR/core/target/classes/org/akaza/openclinica/job/XsltTransformJob.class ./org/akaza/openclinica/job
jar -uf $CORE_JAR_FILE_NAME ./org/akaza/openclinica/job/ExportLogger.class
jar -uf $CORE_JAR_FILE_NAME ./org/akaza/openclinica/job/XsltTransformJob.class
echo "Done adding export logging patch"



echo "Fixing RuleActionComparator"
mkdir -p ./org/akaza/openclinica/domain/rule/action/
cp $PROJECT_BASE_DIR/core/target/classes/org/akaza/openclinica/domain/rule/action/RuleActionComparator.class ./org/akaza/openclinica/domain/rule/action
jar -uf $CORE_JAR_FILE_NAME ./org/akaza/openclinica/domain/rule/action/RuleActionComparator.class
echo "Done fixing RuleActionComparator"


echo "Fixing Year-of-Birth in SPSS-export"
jar -uf $CORE_JAR_FILE_NAME ./logback-test.xml

jar -uf $CORE_JAR_FILE_NAME ./properties/xslt/odm_to_html.xsl
jar -uf $CORE_JAR_FILE_NAME ./properties/xslt/odm_spss_sps.xsl
jar -uf $CORE_JAR_FILE_NAME ./properties/xslt/odm_spss_dat.xsl
jar -uf $CORE_JAR_FILE_NAME ./properties/xslt/ODMToTAB.xsl
echo "Done fixing Year-of-Birth in SPSS-export"

# update the JAR file only in the web WAR files.
jar -uf ./OpenClinica.war $CORE_JAR_FILE_NAME


mkdir -p ./WEB-INF/classes/org/akaza/openclinica/control/extract


mv ./datainfo.properties ./WEB-INF/classes
jar -uf OpenClinica.war ./WEB-INF/classes/datainfo.properties
jar -uf OpenClinica-ws.war ./WEB-INF/classes/datainfo.properties

cp $PROJECT_BASE_DIR/web/target/classes/org/akaza/openclinica/control/extract/AccessFileServlet.class ./WEB-INF/classes/org/akaza/openclinica/control/extract/
jar -uf OpenClinica.war ./WEB-INF/classes/org/akaza/openclinica/control/extract/AccessFileServlet.class
jar -uf OpenClinica-ws.war ./WEB-INF/classes/org/akaza/openclinica/control/extract/AccessFileServlet.class

#
# the next commands update the login.jsp page with appropriate warnings for the ACCEPTANCE and SANDBOX environments
# 

echo "Adding login page warning messages for SANDBOX and ACCEPTANCE environments"
mkdir -p ./WEB-INF/jsp/login
cp $PROJECT_BASE_DIR/web/src/main/webapp/WEB-INF/jsp/login/login.jsp ./WEB-INF/jsp/login/login.jsp

# PRODUCTION and ARCHIVE first

sed "s/{{{ENVIRONMENT}}}//" login-environ-param.jsp > ./WEB-INF/jsp/login/login.jsp
jar -uf OpenClinica.war ./WEB-INF/jsp/login/login.jsp
cp ./OpenClinica.war ./OpenClinica-3.6-PROD.war
cp ./OpenClinica.war ./OpenClinica-3.6-ARCHIVE.war
cp ./OpenClinica-ws.war ./OpenClinica-ws-3.6-PROD.war
cp ./OpenClinica-ws.war ./OpenClinica-ws-3.6-ARCHIVE.war

# Next acceptange
sed "s/{{{ENVIRONMENT}}}/>> This is the ACCEPTANCE environment. Do not use for actual clinical trial data entry <</" login-environ-param.jsp > ./WEB-INF/jsp/login/login.jsp
jar -uf OpenClinica.war ./WEB-INF/jsp/login/login.jsp

cp ./OpenClinica.war ./OpenClinica-3.6-ACCEPTANCE.war
cp ./OpenClinica-ws.war ./OpenClinica-ws-3.6-ACCEPTANCE.war

# Next sandbox
sed "s/{{{ENVIRONMENT}}}/>> This is the SANDBOX environment. Do not use for actual clinical trial data entry <</" login-environ-param.jsp > ./WEB-INF/jsp/login/login.jsp
jar -uf OpenClinica.war ./WEB-INF/jsp/login/login.jsp

cp ./OpenClinica.war ./OpenClinica-3.6-SANDBOX.war
cp ./OpenClinica-ws.war ./OpenClinica-ws-3.6-SANDBOX.war

echo "removing modified login page login-environ-param.jsp"

echo "Done login page warning messages"

echo "Cleaning up"
rm ./login-environ-param.jsp

rm -rf ./org
rm -rf ./images
rm -rf ./includes
rm -rf ./WEB-INF
rm ./logback-test.xml
rm -rf ./properties




cd $CURRENT_DIR
cp ../upgrades/deploy-oc3.6.sh ~/package-patches



rm -rf ./core/
rm -rf ./web/
echo "Finished"
echo "Modified OpenClinica WAR file can be found in ~/package-patches"

