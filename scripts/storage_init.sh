#!/bin/bash
echo "Starting init of dataClay [@storage_init.sh]"
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
dataclaysrv start --hosts "$HOSTS" $DATACLAYSRV_START_CMD
#-------------------------------------- COMPSs specifc -------------------------------------------------
# Get session config
JOB_CONFIG="$HOME/.dataClay/$DATACLAY_JOBID/client.config"
source $JOB_CONFIG

echo "Symbolic linking $DATACLAYSESSIONCONFIG to COMPSs folder"
mkdir -p ~/.COMPSs/${jobId}/storage/cfgfiles
ln -s $DATACLAYSESSIONCONFIG ~/.COMPSs/${jobId}/storage/cfgfiles/storage.properties
