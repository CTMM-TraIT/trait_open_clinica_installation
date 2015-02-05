#!/bin/sh
# ==============================================================================
#
# Script to automatically deploy the fix introduced for OC-4783. Four xslt files
# are replaced by the fixed versions. The assumption is that Tomcat can be found
# under a directory (or link) called 'tomcat'. This should be the case for all
# the four OpenClinica environments (PRODUCTION, ACCEPTANCE, SANDBOX and ARCHIVE). 
# This script MUST be run from the home directory of user 'clinica'
#
# ==============================================================================
tar -xvf OC-4783-patch.tar.gz
cd ./fix-OC-4783/
cp ../tomcat/openclinica.data/xslt/ODMToTAB.xsl ../tomcat/openclinica.data/xslt/ODMToTAB.xsl.bak
cp ../tomcat/openclinica.data/xslt/odm_to_html.xsl ../tomcat/openclinica.data/xslt/odm_to_html.xsl.bak 
cp ../tomcat/openclinica.data/xslt/odm_spss_dat.xsl ../tomcat/openclinica.data/xslt/odm_spss_dat.xsl.bak
cp ../tomcat/openclinica.data/xslt/odm_spss_sps.xsl ../tomcat/openclinica.data/xslt/odm_spss_sps.xsl.bak


cp ./*.xsl ../tomcat/openclinica.data/xslt/

cd ..
