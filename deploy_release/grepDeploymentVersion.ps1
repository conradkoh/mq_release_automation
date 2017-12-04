function grepVersion($versionDirectory, $versionFilename) {
	echo "=================================================="
	echo "Extracting version from version.txt file."
	echo "=================================================="
	echo "Version directory: $($versionDirectory)"
	echo "Version filename : $($versionFilename)"
	echo ""
	
	echo "Checking if version directory exists."
	if ((Test-Path "$($versionDirectory)") -eq $false) {
		throw "Directory $($versionDirectory) does not exist."
	}
	echo "Done!"
	echo ""
	
	echo "Checking if version filename exists."
	if ((Test-Path "$($versionDirectory)\$($versionFilename)") -eq $false) {
		throw "File $($versionDirectory)\$($versionFilename) does not exist."
	}
	echo "Done!"
	echo ""
	
	echo "Extracting version number from $($versionDirectory)\$($versionFilename)."
	$lines = (Get-Content ("$($versionDirectory)\$($versionFilename)"))
	# Line[0] will be the new version text
	# Line[1] will be the new version number
	# Line[2] will be the old version text
	# Line[3] will be the old version number
	echo "Data extracted from $($versionDirectory)\$($versionFilename)"
	echo "Line[0]: $($lines[0])"
	echo "Line[1]: $($lines[1])"
	echo "Line[2]: $($lines[2])"
	echo "Line[3]: $($lines[3])"
	echo ""
	
	generateVersionXml $lines
	return
}

function generateVersionXml($lines) {
	$outputLocation = ".\config\releaseVersionsConfig.xml"

	echo "Generating $($outputLocation)"
	
	# IMPORTANT: Line[3] is old version, line[1] is new version.
	echo "<?xml version=`"1.0`"?>" > $outputLocation
	echo "<configuration>" >> $outputLocation
	echo "	<versionVariables>" >> $outputLocation
	echo "		<add key=`"oldVersionNumber`" value=`"$($lines[3])`" />" >> $outputLocation
	echo "		<add key=`"newVersionNumber`" value=`"$($lines[1])`" />" >> $outputLocation
	echo "	</versionVariables>" >> $outputLocation
	echo "</configuration>" >> $outputLocation
	
	echo "Done!"
	echo ""
	return
}

################################################################################
# SCRIPT START
################################################################################
[xml]$grepDeploymentVersionConfigFile = get-content .\config\grepDeploymentVersionConfig.xml

$versionDirectory = $grepDeploymentVersionConfigFile.configuration.grepDeploymentVersionVariables.add[0].value
$versionFilename = $grepDeploymentVersionConfigFile.configuration.grepDeploymentVersionVariables.add[1].value

echo $versionDirectory
echo $versionFilename
try {
	grepVersion $versionDirectory $versionFilename
} catch {
	throw
}