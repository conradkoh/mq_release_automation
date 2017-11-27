function verifyComponentVersion($commonVariables, $componentVariables, $oldVersion, $newVersion) {
	echo "=================================================="
	echo "verifying source and destination component versions."
	echo "=================================================="
	echo "Source folder path               : $($commonVariables[1])"
	echo "Destination folder path          : $($commonVariables[2])"
	echo "Component source folder path     : $($componentVariables[0])"
	echo "Component destination folder path: $($componentVariables[1])"
	echo "Old version                      : $($oldVersion)"
	echo "New version                      : $($newVersion)"
	
	$Filename = "deployment_version.php"
	$sourceLineIndex = -1
	$destinationLineIndex = -1
	# Patch folder will be in the form of {folderName}_f{oldVersion}_t{newVersion}
	$constructedSourceFile = "$($commonVariables[1])\$($componentVariables[0])_t$($newVersion)_f$($oldVersion)\$($filename)"
	$constructedDestinationFile = "$($commonVariables[2])\$($componentVariables[1])\$($filename)"
	echo "Constructed source file          : $($constructedSourceFile)"
	echo "Constructed destination file     : $($constructedDestinationFile)"
	
	# We check if the file exists. If it doesn't we throw an exception
	if ((test-path $constructedSourceFile) -eq $false) {
		throw "$($constructedSourceFile) does not exist."
	}
	$sourceLines = (Get-Content "$($constructedSourceFile)")
	
	
	if ((test-path $constructedDestinationFile) -eq $false) {
		throw "$($constructedDestinationFile) does not exist."
	}
	$destinationLines = (Get-Content "$($constructedDestinationFile)")
	
	
	# We check for the existance of the version number extracted from version.txt with the php file that contains the release version.
	$sourceLineIndex = searchLines $sourceLines $newVersion
	if($sourceLineIndex -eq -1) {
		throw "Source path version mismatch. $($sourceLineIndex) in $($constructedSourceFile) does not match $($newVersion) in version.txt"
	}

	$destinationLineIndex = searchLines $destinationLines $oldVersion
	if($destinationLineIndex -eq -1) {
		throw "Source path version mismatch. $($destinationLineIndex) in $($constructedDestinationFile) does not match $($oldVersion) in version.txt"
	}
	
	echo "New Version: $($newVersion) found in $($constructedSourceFile)"
	echo "Old Version: $($oldVersion) found in $($constructedDestinationFile)"
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
			verifyComponentVersion $commonVariables $componentsList[$i] $oldVersion $newVersion
		} catch {
			throw
		}
	}
}
