#!/bin/bash

#=== FUNCTION ================================================================
# NAME: download_singularity_image
# DESCRIPTION: Get singularity image if not exists
# PARAMETER 1: Image name 
#===============================================================================
function download_singularity_image { 
	IMAGE_NAME=$1
	IMAGE_PATH=$SCRIPTDIR/singularity/images/${IMAGE_NAME}.sif
	if [ -f $IMAGE_PATH ]; then 
		echo "WARNING: Found ${IMAGE_NAME} singularity image $IMAGE_PATH. Skipping."
	else
		echo "Downloading $IMAGE_NAME singularity image into $IMAGE_PATH"
		singularity pull $IMAGE_PATH library://support-dataclay/default/${IMAGE_NAME}:${DATACLAY_VERSION}
	fi 
}

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
DATACLAY_VERSION=$(cat $SCRIPTDIR/VERSION.txt)
echo "Installing dataClay $DATACLAY_VERSION"
download_singularity_image logicmodule
download_singularity_image dsjava 
download_singularity_image dspython 
download_singularity_image client
echo "Installing client dependencies"
$SCRIPTDIR/client/install_client_dependencies.sh
