function recoverPortalDatabaseFolder ($destinationFolder, $portalDatabaseDestination, $portalDatabaseBackupFileLocation) {
	echo "=================================================="
	echo "| Initiating recovery of database folder."
	echo "=================================================="
	echo "Destination folder path          : $($destinationFolder)"
	echo "Database destination folder path : $($portalDatabaseDestination)"
	echo "Zipped file name and location    : $($portalDatabaseBackupFileLocation)"
	$resolvedConstructedPath = resolve-path "$($destinationFolder)/$($portalDatabaseDestination)"
	echo "Resolved constructed path        : $($resolvedConstructedPath)"
	$currentDate = date -f yyyyMMdd_HHmmss
	
	rename-item "$($resolvedConstructedPath)" "$($resolvedConstructedPath)_$($currentDate)"
	mkdir "$($resolvedConstructedPath)"
	Add-Type -assembly "system.io.compression.filesystem"
	[io.compression.zipfile]::ExtractToDirectory("$($portalDatabaseBackupFileLocation)", "$($resolvedConstructedPath)")
}



function recoverPortalReportingFolder ($destinationFolder, $portalReportingDestination, $portalReportingBackupFileLocation) {
	echo "=================================================="
	echo "| Initiating recovery of reporting folder."
	echo "=================================================="
	echo "Destination folder path          : $($destinationFolder)"
	echo "Reporting destination folder path: $($portalReportingDestination)"
	echo "Zipped file name and location    : $($portalReportingBackupFileLocation)"
	$resolvedConstructedPath = resolve-path "$($destinationFolder)/$($portalReportingDestination)"
	echo "Resolved constructed path        : $($resolvedConstructedPath)"
	$currentDate = date -f yyyyMMdd_HHmmss
	
	rename-item "$($resolvedConstructedPath)" "$($resolvedConstructedPath)_$($currentDate)"
	mkdir "$($resolvedConstructedPath)"
	Add-Type -assembly "system.io.compression.filesystem"
	[io.compression.zipfile]::ExtractToDirectory("$($portalReportingBackupFileLocation)", "$($resolvedConstructedPath)")
}



function recoverPortalPortalFolder ($destinationFolder, $portalPortalDestination, $portalPortalBackupFileLocation) {
	echo "=================================================="
	echo "| Initiating recovery of portal folder."
	echo "=================================================="
	echo "Destination folder path          : $($destinationFolder)"
	echo "Portal destination folder path: $($portalPortalDestination)"
	echo "Zipped file name and location    : $($portalPortalBackupFileLocation)"
	$resolvedConstructedPath = resolve-path "$($destinationFolder)/$($portalPortalDestination)"
	echo "Resolved constructed path        : $($resolvedConstructedPath)"
	$currentDate = date -f yyyyMMdd_HHmmss
	
	rename-item "$($resolvedConstructedPath)" "$($resolvedConstructedPath)_$($currentDate)"
	mkdir "$($resolvedConstructedPath)"
	Add-Type -assembly "system.io.compression.filesystem"
	[io.compression.zipfile]::ExtractToDirectory("$($portalPortalBackupFileLocation)", "$($resolvedConstructedPath)")
}



################################################################################
# SCRIPT START
################################################################################
# Steps:
#    Rename files from enabled components
#    Extract files from zipped folders
#    We never delete the folders just to be on the safe side

#iisreset /stop



[xml]$deploymentDateConfigFile = get-content .\config\deploymentDateConfig.xml
[xml]$commonConfigFile = get-content .\config\commonConfig.xml
[xml]$releaseVersionConfigFile = get-content .\config\releaseVersionsConfig.xml
[xml]$enabledComponentsConfigFile = get-content .\config\enabledComponentsConfig.xml
[xml]$backupVersionsConfigFile = get-content .\config\backupVersionsConfig.xml

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

$portalDatabaseBackupFileLocation = $backupVersionsConfigFile.configuration.backupVariables.add[0].value
$portalReportingBackupFileLocation = $backupVersionsConfigFile.configuration.backupVariables.add[1].value
$portalPortalBackupFileLocation = $backupVersionsConfigFile.configuration.backupVariables.add[2].value



if($isDatabase -eq "true") {
	recoverPortalDatabaseFolder $destinationFolder $portalDatabaseVariables[1] $portalDatabaseBackupFileLocation
} else {
}

if($isReporting -eq "true") {
	recoverPortalReportingFolder $destinationFolder $portalReportingVariables[1] $portalReportingBackupFileLocation
} else {
}

if($isPortal -eq "true") {
	recoverPortalPortalFolder $destinationFolder $portalPortalVariables[1] $portalPortalBackupFileLocation
} else {
}

Add-Type -assembly "system.io.compression.filesystem"




#iisreset /start



