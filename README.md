# trait_openclinica_installation

This project contains scripts and fixes which are run on the CTMM-TraIT OpenClinica environments after upgrades or after new installs. The way to run these scripts is described in the upgrade manuals. The latest version can be found in Alfreso under the directory tree:

WP1/OpenClinica/Manuals/Software-upgrade.

The current version is  of OpenClinica is 3.6. This upgrade was run with a script which can be found on GitHub:
https://github.com/CTMM-TraIT/trait_open_clinica_installation/tree/master/upgrades


This project contains 2 bash-scritps which perform the following steps:

- /patches/package-patches.sh: creates new WAR's with the TraIT patches using the latest OpenClinica WAR as target
- /upgrades/deploy-oc3.6.sh: deploys the patched OpenCLinica 3.6 WAR while taking care of backups etc.

N.B. the file /patches/deploy-patches.sh is not used any more.
 

The patches are found in the directory /patches and /rebranding and include:

- Rebranding: contains a ZIP-file with the logo's, bash-scripts and the modified JSP's for the rebranding of OpenClinica. Each environment has it's own script (PROD, ACC, SANDBOX and ARCHIVE). 

- Fix for OC-4783. This fix addreses the problem that no year-of-birth of a subject is not exported. OC has not yet included the fix in the main-code branch. A XSLT-file is updated.

- Addition of extra logging incase of exports. The reciepient's e-mail address(es), the names and technical-ID's of fields exported, the study, the userID of the requestor, the export format and the dataset name are explicitly logged. This was requested by a security-officer of a hospital. 
The modified classes are added to the core-library jar-file with a script. The entire packed is located in the 'patches' directory. These changes have been submitted to OpenClinica but have not yet been accepted. The output is sent to a separate logfile called 'openclinica-exports.log' which is rolled over monthly; c.f. the logging-test.xml file also included in the ExportLogging.tar.gz file. 

- Fix for a problem when browing through the Discrepancy-Note list (OC-6757 / OC-5697 and TraIT1509 330). Two Java files are patched
