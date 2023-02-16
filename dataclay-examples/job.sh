#!/bin/bash -e
#SBATCH --job-name=fabrictest
#SBATCH --output=job-%A.out
#SBATCH --error=job-%A.out
#SBATCH --nodes=3
#SBATCH --time=00:05:00
#SBATCH --exclusive 
#SBATCH --qos=debug
#############################

# Load Dataclay
module load DATACLAY/DevelMarc

# Get node hostnames with network suffix
network_suffix="-ib0"
hostnames=($(scontrol show hostname $SLURM_JOB_NODELIST | sed "s/$/$network_suffix/"))

# Create hosts file
hosts_file=hosts-$SLURM_JOB_ID
echo "[metadata]" > $hosts_file
echo ${hostnames[0]} >> $hosts_file
echo "[backends]" >> $hosts_file 
printf "%s\n" ${hostnames[@]:1} >> $hosts_file

# Set environment variables
export PYTHONPATH=$PYTHONPATH:$PWD
export DATACLAY_METADATA_HOSTNAME=${hostnames[0]} # DO NOT EDIT!
export KV_HOST=${hostnames[0]} # DO NOT EDIT!
export DEBUG=true
export DC_USERNAME=testuser
export DC_PASSWORD=s3cret
export DC_DATASET=testuser

# Set tracing variables
export TRACING=false
export OTEL_EXPORTER_OTLP_ENDPOINT=http://${hostnames[0]}:4317 # DO NOT EDIT!
export OTEL_TRACES_SAMPLER=traceidratio
export OTEL_TRACES_SAMPLER_ARG=0.1
export OTEL_SERVICE_NAME=client

dataclay-deploy -i $hosts_file -v

python3 script.py

sleep 30