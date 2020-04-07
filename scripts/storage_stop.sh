#!/bin/bash

echo "Starting teardown of dataClay [@storage_stop.sh]"
#############################################################
# Name: storage_stop.sh
# Description: Storage API script for COMPSs
# Parameters: <jobId>              Queue Job Id
#             <masterNode>         COMPSs Master Node
#             <storageMasterNode>  Node reserved for Storage Master Node (if needed)
#             "<workerNodes>"      Nodes set as COMPSs workers
#             <network>            Network type
#             <storage_props>      Storage Properties file
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
# DESCRIPTION: Display error
# PARAMETER 1: --
#=============================================================================
display_error() {
	echo "ERROR: $errorMsg"
	exit 1
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
source $storageProps
export DATACLAY_JOBID=$jobId
dataclaysrv stop $DATACLAYSRV_STOP_CMD

