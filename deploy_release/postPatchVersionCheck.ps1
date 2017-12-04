function verifyComponentVersionPostPatch($commonVariables, $componentVariables, $newVersion) {
	echo "=================================================="
	echo "Post patch version verification."
	echo "=================================================="
	echo "Destination folder path           : $($commonVariables[2])"
	echo "Component destination folder path : $($componentVariables[1])"
	echo "New Version                       : $($newVersion)"
	
	$Filename = "deployment_version.php"
	$destinationLineIndex = -1
	
	$constructedDestinationFile = "$($commonVariables[2])\$($componentVariables[1])\$($filename)"
	echo "Constructed destination file      : $($constructedDestinationFile)"
	
	if ((test-path $constructedDestinationFile) -eq $false) {
		throw "$($constructedDestinationFile) does not exist."
	}
	
	$destinationLines = (get-content "$($constructedDestinationFile)")


	$destinationLineIndex = searchLines $destinationLines $newVersion
	if($destinationLineIndex -eq -1) {
		throw "Source path version mismatch. $($destinationLineIndex) in $($constructedDestinationFile) does not match $($oldVersion) in version.txt"
	}
	
	echo "Patching successful: $($newVersion) is verified to exist in $($constructedDestinationFile)"

}

function searchLines ($lines, $searchString) {
	for($i = 0; $i -lt $lines.length; $i++) {
		if($lines[$i].ToLower().Contains($searchString.ToLower()) -eq $true) {
			$i
			return
		}
	}
	$i = -1
	$i
	return
}







################################################################################
# SCRIPT START
################################################################################

# Assumption: version verification will be done on deploymentVersion.php in both
#             source and target folders of portal folder.

[xml]$deploymentDateConfigFile = get-content .\config\deploymentDateConfig.xml
[xml]$releaseVersionsConfigFile = get-content .\config\releaseVersionsConfig.xml
[xml]$commonConfigFile = get-content .\config\commonConfig.xml
[xml]$enabledComponentsConfigFile = get-content .\config\enabledComponentsConfig.xml

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

$componentsList = $portalDatabaseVariables,
						$portalReportingVariables,
						$portalPortalVariables
# index 0: Database
# index 1: Reporting
# index 2: Portal
$enabledComponentsList = $enabledComponentsConfigFile.configuration.enabledComponentsVariables.add[0].value,
							$enabledComponentsConfigFile.configuration.enabledComponentsVariables.add[1].value,
							$enabledComponentsConfigFile.configuration.enabledComponentsVariables.add[2].value

for ($i = 0; $i -lt $enabledComponentsList.length; $i++) {
	if($enabledComponentsList -eq "true") {
		try {
			verifyComponentVersionPostPatch $commonVariables $componentsList[$i] $newVersion
		} catch {
			# TODO: invoke recovery script.
			throw
		}
	}
}
