function generateDeploymentDateXml() {

	$currentDate = date -f yyyyMMdd-HHmm
	$outputLocation = ".\config\deploymentDateConfig.xml"
	echo "<?xml version=`"1.0`"?>" > $outputLocation
	echo "<configuration>" >> $outputLocation
	echo "	<deploymentDate>" >> $outputLocation
	echo "		<add key=`"deploymentDate`" value=`"$currentDate`"/>" >> $outputLocation
	echo "	</deploymentDate>" >> $outputLocation
	echo "</configuration>" >> $outputLocation
}

################################################################################
# SCRIPT START
################################################################################
generateDeploymentDateXml