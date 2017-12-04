# Database folder patching.
function patchPortalDatabaseFolder($portalDatabaseVariables, $deploymentDate, $oldVersion, $newVersion, $sourceFolder, $destinationFolder) {
	echo "=================================================="
	echo "| Patching Portal Database Folder."
	echo "=================================================="
	echo "Source Directory            : $($portalDatabaseVariables[0])"
	echo "Destination Directory       : $($portalDatabaseVariables[1])"
	echo "Old Version                 : $($oldVersion)"
	echo "New Version                 : $($newVersion)"
	# Assertion: Database patch will always overwrite whatever's in the database destination folder.
	$constructedSourcePath = "$($sourceFolder)\$($portalDatabaseVariables[0])_t$($newVersion)_f$($oldVersion)"
	$constructedDestinationPath = "$($destinationFolder)\$($portalDatabaseVariables[1])"
	echo "Constructed source path     : $($constructedSourcePath)"
	echo "Constructed destination path: $($constructedDestinationPath)"


	echo "Checking if source directory $($constructedSourcePath) exists."
	if ((Test-Path $($constructedSourcePath)) -eq $false) {
		throw "Directory $($constructedSourcePath) does not exist, please check XML file for any potential errors."
	}
	echo "Done!"

	echo "Checking if destination directory $($constructedDestinationPath) exists."
	if ((Test-Path $($constructedDestinationPath)) -eq $false) {
		throw "Directory $($constructedDestinationPath) does not exist, please check XML file for any potential errors."
	}
	echo "Done!"
	
	echo "Patching files in $($constructedDestinationPath)"
	# Sync files then enter destination directory, invoke flyway migrate, then return to script directory.
	# Copy only files that does not exist in destination folder.
	#robocopy /xc /xn /xo $portalDatabaseVariables[0] $portalDatabaseVariables[1] >> log.txt
	robocopy -is -it $constructedSourcePath $constructedDestinationPath >> log.txt
	$oldPath = pwd
	cd $constructedDestinationPath
	flyway info >> $oldPath/log.txt
	echo "Invoking flyway migrate."
	#flyway migrate
	cd $oldPath
	echo "Done!"
}

# Portal folder patching
function patchPortalPortalFolder($portalPortalVariables, $deploymentDate, $oldVersion, $newVersion, $sourceFolder, $destinationFolder) {
	echo "=================================================="
	echo "| Patching Portal Portal Folder."
	echo "=================================================="
	echo "Source Directory            : $($portalPortalVariables[0])"
	echo "Destination Directory       : $($portalPortalVariables[1])"
	echo "Old Version                 : $($oldVersion)"
	echo "New Version                 : $($newVersion)"
	# Assertion: Portal patch will always overwrite whatever's in portal destination folder.
	$constructedSourcePath = "$($sourceFolder)\$($portalPortalVariables[0])_t$($newVersion)_f$($oldVersion)"
	$constructedDestinationPath = "$($destinationFolder)\$($portalPortalVariables[1])"
	echo "Constructed source path     : $($constructedSourcePath)"
	echo "Constructed destination path: $($constructedDestinationPath)"
	
	echo "Checking if source directory $($constructedSourcePath) exists."
	if ((Test-Path $($constructedSourcePath)) -eq $false) {
		throw "Directory $($constructedSourcePath) does not exist, please check XML file for any potential errors."
	}
	echo "Done!"

	echo "Checking if destination directory $($constructedDestinationPath) exists."
	if ((Test-Path $($constructedDestinationPath)) -eq $false) {
		throw "Directory $($constructedDestinationPath) does not exist, please check XML file for any potential errors."
	}
	echo "Done!"
	
	echo "Patching files in $($constructedDestinationPath)"
	robocopy -is -it $constructedSourcePath $constructedDestinationPath >> log.txt
	echo "Done!"
}

# Reporting folder patching
function patchPortalReportingFolder($portalReportingFolder, $deploymentDate, $oldVersion, $newVersion, $sourceFolder, $destinationFolder) {
	echo "=================================================="
	echo "| Patching Portal Reporting Folder."
	echo "=================================================="
	echo "Source Directory            : $($portalReportingVariables[0])"
	echo "Destination Directory       : $($portalReportingVariables[1])"
	echo "Old Version                 : $($oldVersion)"
	echo "New Version                 : $($newVersion)"
	# Assertion: Reporting patch will always copy and paste into reporting destination folder.
	$constructedSourcePath = "$($sourceFolder)\$($portalReportingVariables[0])_t$($newVersion)_f$($oldVersion)"
	$constructedDestinationPath = "$($destinationFolder)\$($portalReportingVariables[1])"
	echo "Constructed source path     : $($constructedSourcePath)"
	echo "Constructed destination path: $($constructedDestinationPath)"
	
	echo "Checking if source directory $($constructedSourcePath) exists."
	if ((Test-Path $($constructedSourcePath)) -eq $false) {
		throw "Directory $($constructedSourcePath) does not exist, please check XML file for any potential errors."
	}
	echo "Done!"

	echo "Checking if destination directory $($constructedDestinationPath) exists."
	if ((Test-Path $($constructedDestinationPath)) -eq $false) {
		throw "Directory $($constructedDestinationPath) does not exist, please check XML file for any potential errors."
	}
	echo "Done!"
	
	robocopy -is -it $constructedSourcePath $constructedDestinationPath >> log.txt
}

################################################################################
# SCRIPT START
################################################################################
# Assumption: Network drive containing the patch files is already mapped.
# Assertion: Backup is already done via another script.

#iisreset /stop

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

echo "Deployment date: $deploymentDate"
echo "Deployment environment: $environment"
echo "Patch folder root: $sourceFolder"
echo "Destination folder root: $destinationFolder"
echo ""
echo "Old version: $($oldVersion)"
echo "New version: $($newVersion)"
echo ""
echo "Portal database source directory: $($portalDatabaseVariables[0])"
echo "Portal database destination directory: $($portalDatabaseVariables[1])"
echo "Portal reporting source directory: $($portalReportingVariables[0])"
echo "Portal reporting destination directory: $($portalReportingVariables[1])"
echo "Portal portal source directory: $($portalPortalVariables[0])"
echo "Portal portal destination directory: $($portalPortalVariables[1])"




# Patching

if($isDatabase -eq "true") {
	try {
		patchPortalDatabaseFolder $portalDatabaseVariables $deploymentDate $oldVersion $newVersion $sourceFolder $destinationFolder
	} catch {
		throw
	}
}

if($isReporting -eq "true") {
	try {
		patchPortalReportingFolder $portalReportingVariables $deploymentDate $oldVersion $newVersion $sourceFolder $destinationFolder
	} catch {
		throw
	}
}

if($isPortal -eq "true") {
	try {
		patchPortalPortalFolder $portalPortalVariables $deploymentDate $oldVersion $newVersion $sourceFolder $destinationFolder
	} catch {
		throw
	}
}















#iisreset /start
echo ""
echo ""
echo ""