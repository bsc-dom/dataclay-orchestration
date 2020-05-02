#!/bin/bash
#############################################################
# Name: storage_init.sh
# Description: Storage API script for COMPSs
# Parameters: <jobId>              Queue Job Id
#             <masterNode>         COMPSs Master Node
#             <storageMasterNode>  Node reserved for Storage Master Node (if needed)
#             "<workerNodes>"      Nodes set as COMPSs workers
#             <network>            Network type
#             <storageProps>       Properties file for storage specific variables
#############################################################

#=== FUNCTION ================================================================
# NAME: usage
# DESCRIPTION: Display usage information for this script.
# PARAMETER 1: exit value
#=============================================================================
usage() {
    local exitValue=$1
    echo " Usage: $0 <jobId> <masterNode> <storageMasterNode> \"<workerNodes>\" <network> <storageProps>"
    echo " "
    exit $exitValue
}

#=== FUNCTION ================================================================
# NAME: usage
# DESCRIPTION: Display usage information for this script.
# PARAMETER 1: ---
#=============================================================================
get_args() {
	NUM_PARAMS=6
	# Check parameters
	if [ $# -eq 1 ]; then
		if [ "$1" == "usage" ]; then
			usage 0
		fi
	fi
	# Get parameters
	jobId=$1
	master_node=$2
	storage_master_node=$3
	worker_nodes=$4
	network=$5
	storageProps=$6
}
# -------------- 


get_args "$@"

if [ ! -f ${storageProps} ]; then
	# PropsFile doesn't exist
	echo "ERROR: storage properties file ${storageProps} does not exist" 
	exit 1
fi

NETWORK_SUFFIX=""
if [ "${network}" == "infiniband" ]; then
	NETWORK_SUFFIX="-ib0"
fi

#----------------------------------------- SLURM -------------------------------------------------
HOSTS="$storage_master_node $worker_nodes"
# Get hosts and add infiniband suffix if needed
for HOST in $JOB_HOSTS; do
        HOSTS="$HOSTS ${HOST}${NETWORK_SUFFIX}"
done
export DATACLAY_JOBID=$jobId
#---------------------------------------- Start dataClay ----------------------------------------------
source $storageProps

# Get version
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
DATACLAY_BASE=$SCRIPTDIR/..
DATACLAY_VERSION=$(cat $DATACLAY_BASE/VERSION.txt)

# Specify python virtual environment 
PYTHONVERSION=$(python --version | awk '{print $2}')
SIMPLIFIED_PYTHONVERSION=$( cut -d '.' -f 1,2 <<< "$PYTHONVERSION" )

echo "[@storage_init.sh] Initializing dataClay $DATACLAY_VERSION"
echo "[@storage_init.sh] INFO: Found Python version $PYTHONVERSION "

DATACLAYSRV_START_CMD="--container-python-version $SIMPLIFIED_PYTHONVERSION $DATACLAYSRV_START_CMD" # server will use this python version singularity image
DATACLAYSRV_START_CMD="--pyclay-path $PYCLAY_PATH $DATACLAYSRV_START_CMD"
DATACLAYSRV_START_CMD="--javaclay-path $DATACLAY_JAR $DATACLAYSRV_START_CMD"

# Specify extrae wrapper 
if [[ $DATACLAYSRV_START_CMD == *"--tracing"* ]]; then
	if [ -z $EXTRAE_HOME ]; then 
		EXTRAE_VERSION=$DATACLAY_DEFAULT_EXTRAE_VERSION
	else 
		EXTRAE_VERSION=$(echo "${EXTRAE_HOME//\/apps\/BSCTOOLS\/extrae\//}" | awk -F "/" '{print $1}')
		echo " [@storage_init.sh] **** Warning **** Found Extrae version $EXTRAE_VERSION "
	fi
	echo "[@storage_init.sh] INFO: Using Extrae version $EXTRAE_VERSION "
	DATACLAYSRV_START_CMD="--dataclay-extrae-wrapper /apps/DATACLAY/dependencies/extrae_wrapper/lib/dataclay_extrae_wrapper${EXTRAE_VERSION}.so $DATACLAYSRV_START_CMD"
fi

dataclaysrv start --hosts "$HOSTS" $DATACLAYSRV_START_CMD

#-------------------------------------- COMPSs specifc -------------------------------------------------
# Get session config
JOB_CONFIG="$HOME/.dataClay/$DATACLAY_JOBID/client.config"
source $JOB_CONFIG

# Specify number of hosts
if [ $TRACING == true ]; then
	IFS=' ' read -r -a HOSTS_ARRAY <<< "$HOSTS"
	COUNT=${#HOSTS_ARRAY[@]}
    echo "ExtraeStartingTaskID=$COUNT" >> $DATACLAYSESSIONCONFIG    
fi


echo "[@storage_init.sh] Symbolic linking $DATACLAYSESSIONCONFIG to COMPSs folder"
mkdir -p ~/.COMPSs/${jobId}/storage/cfgfiles
ln -s $DATACLAYSESSIONCONFIG ~/.COMPSs/${jobId}/storage/cfgfiles/storage.properties

echo "[@storage_init.sh] Ready!"

