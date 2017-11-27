





################################################################################
# SCRIPT START
################################################################################
# Steps:
#    Remove files from enabled components
#    Extract files from zipped folders

[xml]$deploymentDateConfigFile = get-content .\config\deploymentDateConfig.xml
[xml]$commonConfigFile = get-content .\config\commonConfig.xml
[xml]$releaseVersionConfigFile = get-content .\config\releaseVersionsConfig.xml
[xml]$enabledComponentsConfigFile = get-content .\config\enabledComponentsConfig.xml

$deploymentDate = $deploymentDateConfigFile.configuration.deploymentDate.add.value					# Deployment date.

$environment = $commonConfigFile.configuration.commonVariables.add[0].value							# Staging or Deployment.
$sourceFolder = $commonConfigFile.configuration.commonVariables.add[1].value							# Where the patch files are located at.
$destinationFolder = $commonConfigFile.configuration.commonVariables.add[2].value					# Where the location of the folder to be patched is at.

$portalDatabaseVariables = $commonConfigFile.configuration.portalDatabaseVariables.add[0].value,	# Source directory where new database files are located.
							$commonConfigFile.configuration.portalDatabaseVariables.add[1].value	# Destination directory where database files are to be copied to.

$portalReportingVariables = $commonConfigFile.configuration.portalReportingVariables.add[0].value,	# Source directory where the new reporting files are located.
							$commonConfigFile.configuration.portalReportingVariables.add[1].value	# Destination directory where reporting files are to be copied to.

$portalPortalVariables = $commonConfigFile.configuration.portalPortalVariables.add[0].value,		# Source directory where the new portal files are located.
							$commonConfigFile.configuration.portalPortalVariables.add[1].value		# Destination directory where portal files are to be copied to.

$oldVersion = $releaseVersionConfigFile.configuration.versionVariables.add[0].value					# Old Version Number
$newVersion = $releaseVersionConfigFile.configuration.versionVariables.add[1].value					# New Version Number

$isDatabase = $enabledComponentsConfigFile.configuration.enabledComponentsVariables.add[0].value	# Is database component enabled
$isReporting = $enabledComponentsConfigFile.configuration.enabledComponentsVariables.add[1].value	# Is reporting component enabled
$isPortal = $enabledComponentsConfigFile.configuration.enabledComponentsVariables.add[2].value		# Is portal component enabled