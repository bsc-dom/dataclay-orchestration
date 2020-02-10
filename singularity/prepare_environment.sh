#! /bin/bash
if [ -z $DATACLAY_STORAGE_PATH ] | [ -z $DATACLAY_LOGICMODULE_IP ]; then
	echo "Please, set the environment variables DATACLAY_STORAGE_PATH and DATACLAY_LOGICMODULE_IP"
	exit
fi

STORAGE_PATH=$DATACLAY_STORAGE_PATH
STORAGE_PATH="/tmp/a"

WORKDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
JOB_FOLDER="$WORKDIR/job"
CONF_FOLDER="$JOB_FOLDER/cfgfiles"
DATACLAYGLOBALCONFIG="$CONF_FOLDER/global.properties"
SC_TEMPLATES_FOLDER="$WORKDIR/singularity-compose-templates"

DEPLOY_PATH="$STORAGE_PATH/deploy_path/"
DEPLOY_PATH_SRC="$DEPLOY_PATH/src"

function generate_singularity_compose {
	SINGULARITY_COMPOSE_FILE=$JOB_FOLDER/singularity-compose.yml

	cat $SC_TEMPLATES_FOLDER/header.yml > $SINGULARITY_COMPOSE_FILE

	if [ "$DATACLAY_LOGICMODULE_IP" == "$(hostname -i)" ]; then
		cat $SC_TEMPLATES_FOLDER/LM.yml >> $SINGULARITY_COMPOSE_FILE
	fi
	if [ $DATACLAY_DS_JAVA -eq 1 ] | [ $DATACLAY_DS_PYTHON -eq 1 ] ; then
		cat $SC_TEMPLATES_FOLDER/DS-java.yml >> $SINGULARITY_COMPOSE_FILE
	fi
	if [ $DATACLAY_DS_PYTHON -eq 1 ]; then
		cat $SC_TEMPLATES_FOLDER/DS-python.yml >> $SINGULARITY_COMPOSE_FILE
	fi
}

# Clean job and storage folders, prepare cfgfiles and link images/scripts
rm -rf "$JOB_FOLDER" "$STORAGE_PATH"
mkdir -p "$JOB_FOLDER"  "$CONF_FOLDER" "$DEPLOY_PATH" "$DEPLOY_PATH_SRC" "$STORAGE_PATH"

ln -s "$WORKDIR/images"  "$JOB_FOLDER/images"
ln -s "$WORKDIR/scripts" "$JOB_FOLDER/scripts"

# Generate cfgfiles
echo "STORAGE_PATH=$STORAGE_PATH" > "$DATACLAYGLOBALCONFIG"
echo "STATE_FILE_PATH=$STORAGE_PATH/state.txt" >> "$DATACLAYGLOBALCONFIG"

## Generate singularity compose file
generate_singularity_compose

# Generate env file
ENV_FILE="$JOB_FOLDER/env.sh"
cp default_environment.sh $ENV_FILE 
echo "export DATACLAYGLOBALCONFIG=$DATACLAYGLOBALCONFIG" >> $ENV_FILE
echo "export DEPLOY_PATH=$DEPLOY_PATH" >> $ENV_FILE
echo "export DEPLOY_PATH_SRC=$DEPLOY_PATH_SRC" >> $ENV_FILE
echo "export LOGICMODULE_HOST=$DATACLAY_LOGICMODULE_IP" >> $ENV_FILE
