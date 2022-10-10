#!/bin/bash -e
#SBATCH --job-name=jobexample
#SBATCH --output=job-%A.out
#SBATCH --error=job-%A.out
#SBATCH --nodes=3
#SBATCH --time=00:03:00
#SBATCH --exclusive 
#SBATCH --qos=debug
#############################

#################
# Configuration # 
#################

# Load Dataclay
module load DATACLAY/DevelMarc

# Get node hostnames with network suffix
network_suffix="-ib0"
hostnames=($(scontrol show hostname $SLURM_JOB_NODELIST | sed "s/$/$network_suffix/"))

# Set environment variables
export METADATA_SERVICE_HOST=${hostnames[0]} # DO NOT EDIT!
export DC_USERNAME=user
export DC_PASSWORD=s3cret
export DEFAULT_DATASET=myDataset
export STUBS_PATH=./stubs
export MODEL_PATH=./model
export NAMESPACE=dcmodel

export TRACING=true
export OTEL_TRACES_SAMPLER=traceidratio
export OTEL_TRACES_SAMPLER_ARG=0.1
export OTEL_SERVICE_NAME=client

#######################
# Dataclay deployment #
#######################

echo "Deploying dataClay"
dcdeploy dataclay -H ${hostnames[@]}

################
# Dataclay app #
################

echo "Starting application"
if [ $TRACING == "true" ]; then
    opentelemetry-instrument python3 -u app/matrix-demo.py 1 0
else
    python3 -u app/matrix-demo.py 1 0
fi

#####################
# Stopping dataclay # 
#####################

echo "Stopping dataclay"
dcdeploy stop -H ${hostnames[@]}
