#!/bin/bash

# Script to sync dataclay and orchestration files to MareNostrum4
# Change the necessary fields!

##############
# TO CHANGE! #
##############

# Name of the dataclay version (change it!)
DATACLAY_VERSION=DevelMarc

# BSC user (change it!)
BSC_USER=bsc25877

# Paths to your local repositories (change it!)
PYCLAY_PATH=~/dev/bsc-dom/pyclay
MDS_PATH=~/dev/bsc-dom/metadata-service
DATACLAY_COMMON_PATH=~/dev/bsc-dom/dataclay-common
JAVACLAY_PATH=~/dev/bsc-dom/javaclay

##############
##############
##############

# Internal MareNostrum paths (do not change!)
MN1_HOST=$BSC_USER@mn1.bsc.es
MN0_HOST=$BSC_USER@mn0.bsc.es
MN_DATACLAY_PATH=/apps/DATACLAY/$DATACLAY_VERSION/
MN_LUA_PATH=/apps/modules/modulefiles/tools/DATACLAY/$DATACLAY_VERSION

# bin & config
rsync -av --delete --copy-links bin $MN1_HOST:$MN_DATACLAY_PATH
rsync -av --delete --copy-links config $MN1_HOST:$MN_DATACLAY_PATH

# pyclay
rsync -av --delete-after --copy-links --filter={":- .gitignore",": /.rsync-filter"} --exclude={.git} $PYCLAY_PATH $MN1_HOST:$MN_DATACLAY_PATH

# metadata-service
rsync -av --delete-after --copy-links --filter={":- .gitignore",": /.rsync-filter"} --exclude={.git} $MDS_PATH $MN1_HOST:$MN_DATACLAY_PATH

# dataclay-common
rsync -av --delete-after --copy-links --filter={":- .gitignore",": /.rsync-filter"} --exclude={.git} $DATACLAY_COMMON_PATH $MN1_HOST:$MN_DATACLAY_PATH

# javaclay
mvn package -Dmaven.test.skip -f $JAVACLAY_PATH &&
ssh $MN1_HOST "mkdir -p ${MN_DATACLAY_PATH}javaclay"
scp $JAVACLAY_PATH/target/dataclay-2.8-SNAPSHOT-jar-with-dependencies.jar $MN1_HOST:${MN_DATACLAY_PATH}javaclay/dataclay.jar

# lua
scp modulefile.lua $MN1_HOST:$MN_LUA_PATH

# dependencies
rsync -av dependencies $MN1_HOST:$MN_DATACLAY_PATH
# Comment the next line if not wanting to create the virtual environments.
# It is necessary a VPN connection in order to use MN0 login (the only login with internet)
ssh $MN0_HOST "cd $MN_DATACLAY_PATH/dependencies && ./install_dependencies.sh"