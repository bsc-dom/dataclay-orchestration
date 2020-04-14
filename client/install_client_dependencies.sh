#!/bin/bash
### Script intended to obtain everything necessary to run client applications without containers ### 
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
EXTRAE_HOME=$SCRIPTDIR/.extrae
DATACLAY_EXTRAE_WRAPPER_LIB=$SCRIPTDIR/pyclay/pyextrae/dataclay_extrae_wrapper.so
DATACLAY_HOME=$SCRIPTDIR/..

while test $# -gt 0
do
	case "$1" in
			--extrae) 
	        	shift
	        	EXTRAE_HOME=$1
	        	;;
			*)  
				echo "Wrong option $1 provided" 
				exit 1
            ;;
    esac
    shift
done

echo "- EXTRAE_HOME = $EXTRAE_HOME"

# sanity check 
rm -rf $SCRIPTDIR/javaclay/
rm -rf $SCRIPTDIR/pyclay 

echo "Obtaining javaclay..."
mkdir -p $SCRIPTDIR/javaclay/
singularity exec $DATACLAY_HOME/singularity/images/logicmodule.sif \
	cp /home/dataclayusr/dataclay/dataclay.jar $SCRIPTDIR/javaclay/dataclay.jar
echo "Obtaining pyclay..."
singularity exec $DATACLAY_HOME/singularity/images/dspython.sif \
	cp -r /home/dataclayusr/dataclay/dataclay_venv $SCRIPTDIR/pyclay/

echo "Obtaining pyextrae..."
singularity exec $DATACLAY_HOME/singularity/images/dspython.sif \
	cp -r /home/dataclayusr/dataclay/pyextrae $SCRIPTDIR/pyclay/

singularity exec $DATACLAY_HOME/singularity/images/logicmodule.sif \
	cp -r /home/dataclayusr/.extrae $EXTRAE_HOME

# Compile dataClay extrae wrapper
pushd $SCRIPTDIR/pyclay/pyextrae 
gcc -L${EXTRAE_HOME}/lib -I${EXTRAE_HOME}/include extrae_wrapper.c \
	-lpttrace -fPIC --shared -o ${DATACLAY_EXTRAE_WRAPPER_LIB}

# Copy extrae configurations 
singularity exec $DATACLAY_HOME/singularity/images/dspython.sif \
	cp /home/dataclayusr/dataclay/extrae/extrae_python.xml $SCRIPTDIR/pyclay/pyextrae
popd

rm -rf $EXTRAE_HOME
