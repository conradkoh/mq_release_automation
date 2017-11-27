function determinePatchComponents($commonVariables, $folderVariables, $oldVersion, $newVersion) {
	echo "=================================================="
	echo "Verifying if components is to be patched"
	echo "=================================================="
	echo "Source folder path: $($commonVariables[1])"
	echo "Component path    : $($folderVariables[0])"
	echo "New version       : $($oldVersion)"
	echo "Old version       : $($newVersion)"
	$constructedSourcePath = "$($commonVariables[1])\$($folderVariables[0])_t$($newVersion)_f$($oldVersion)"
	echo "Constructed path  : $($constructedSourcePath)"
	
	echo "Testing if path exists"
	if ((Test-Path $($constructedSourcePath)) -eq $true) {
		$script:componentEnabled = "true"
	}
}

function generateComponentsEnabledXml($databaseEnabled, $reportingEnabled, $portalEnabled) {
	$outputLocation = ".\config\enabledComponentsConfig.xml"
	echo "<?xml version=`"1.0`"?>" > $outputLocation
	echo "<configuration>" >> $outputLocation
	echo "	<enabledComponentsVariables>" >> $outputLocation
	echo "		<add key=`"isDatabase`" value=`"$databaseEnabled`"/>" >> $outputLocation
	echo "		<add key=`"isReporting`" value=`"$reportingEnabled`"/>" >> $outputLocation
	echo "		<add key=`"isPortal`" value=`"$portalEnabled`"/>" >> $outputLocation
	echo "	</enabledComponentsVariables>" >> $outputLocation
	echo "</configuration>" >> $outputLocation
}

################################################################################
# SCRIPT START
################################################################################
# Assertion: If patch folder does not exist then it means we are not patching
#            that folder. Therefore we will check for the folder's existance.

[xml]$deploymentDateConfigFile = get-content .\config\deploymentDateConfig.xml
[xml]$commonConfigFile = get-content .\config\commonConfig.xml
[xml]$releaseVersionsConfigFile = get-content .\config\releaseVersionsConfig.xml

$script:componentEnabled = "false"
$databaseEnabled = "false"
$reportingEnabled = "false"
$portalEnabled = "false"

$deploymentDate = $deploymentDateConfigFile.configuration.deploymentDate.add.value

$oldVersion = $releaseVersionsConfigFile.configuration.versionVariables.add[0].value
$newVersion = $releaseVersionsConfigFile.configuration.versionVariables.add[1].value

$commonVariables = $commonConfigFile.configuration.commonVariables.add[0].value,
					$commonConfigFile.configuration.commonVariables.add[1].value,
					$commonConfigFile.configuration.commonVariables.add[2].value

$portalDatabaseVariables = $commonConfigFile.configuration.portalDatabaseVariables.add[0].value,
							$commonConfigFile.configuration.portalDatabaseVariables.add[1].value

$portalReportingVariables = $commonConfigFile.configuration.portalReportingVariables.add[0].value,
							$commonConfigFile.configuration.portalReportingVariables.add[1].value

$portalPortalVariables = $commonConfigFile.configuration.portalPortalVariables.add[0].value,
							$commonConfigFile.configuration.portalPortalVariables.add[1].value



determinePatchComponents $commonVariables $portalDatabaseVariables $oldVersion $newVersion
$databaseEnabled = $script:componentEnabled
$script:componentEnabled = "false"

determinePatchComponents $commonVariables $portalReportingVariables $oldVersion $newVersion
$reportingEnabled = $script:componentEnabled
$script:componentEnabled = "false"

determinePatchComponents $commonVariables $portalPortalVariables $oldVersion $newVersion
$portalEnabled = $script:componentEnabled
$script:componentEnabled = "false"

generateComponentsEnabledXml $databaseEnabled $reportingEnabled $portalEnabled
