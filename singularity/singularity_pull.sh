#!/bin/bash

#=== FUNCTION ================================================================
# NAME: get_container_version
# DESCRIPTION: Get container version
# PARAMETER 1: Execution environment version i.e. can be python py3.6 or jdk8
#===============================================================================
function get_container_version { 
	EE_VERSION=$1
	DATACLAY_EE_VERSION="${EE_VERSION//./}"
	if [[ $DATACLAY_VERSION == *".dev"* ]]; then
  		VERSION_WITHOUT_DEV="${DATACLAY_VERSION//.dev/}"
		DATACLAY_CONTAINER_VERSION="${VERSION_WITHOUT_DEV}.${DATACLAY_EE_VERSION}.dev"
  	else 
  		DATACLAY_CONTAINER_VERSION="$DATACLAY_VERSION.${DATACLAY_EE_VERSION}"
	fi
	echo ${DATACLAY_CONTAINER_VERSION}
}
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
ORCHESTRATION_DIR=$SCRIPTDIR/..
source $SCRIPTDIR/PLATFORMS.txt
DATACLAY_VERSION=$(cat ${ORCHESTRATION_DIR}/VERSION.txt)
LOCAL_REPOSITORY=$ORCHESTRATION_DIR/singularity/images
mkdir -p $LOCAL_REPOSITORY
for JAVA_VERSION in ${SUPPORTED_JAVA_VERSIONS[@]}; do
	EXECUTION_ENVIRONMENT_TAG="$(get_container_version jdk$JAVA_VERSION)"
	singularity pull $LOCAL_REPOSITORY/logicmodule:${EXECUTION_ENVIRONMENT_TAG}.sif docker://bscdataclay/logicmodule:$EXECUTION_ENVIRONMENT_TAG
	singularity pull $LOCAL_REPOSITORY/dsjava:${EXECUTION_ENVIRONMENT_TAG}.sif docker://bscdataclay/dsjava:$EXECUTION_ENVIRONMENT_TAG

done
for PYTHON_VERSION in ${SUPPORTED_PYTHON_VERSIONS[@]}; do
	EXECUTION_ENVIRONMENT_TAG="$(get_container_version py$PYTHON_VERSION)"
	singularity pull $LOCAL_REPOSITORY/dspython:${EXECUTION_ENVIRONMENT_TAG}.sif docker://bscdataclay/dspython:$EXECUTION_ENVIRONMENT_TAG
done

singularity pull $LOCAL_REPOSITORY/client:${DATACLAY_VERSION}.sif docker://bscdataclay/client:${DATACLAY_VERSION}

exit 0