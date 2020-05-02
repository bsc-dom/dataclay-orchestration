#!/bin/bash
### Script intended to obtain everything necessary to run client applications without containers ### 
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
DATACLAY_HOME=$SCRIPTDIR/..

# sanity check 
rm -rf $SCRIPTDIR/javaclay/
rm -rf $SCRIPTDIR/pyclay 

echo "Installing javaclay..."
mkdir -p $SCRIPTDIR/javaclay/
singularity exec $DATACLAY_HOME/singularity/images/logicmodule.sif \
	cp /home/dataclayusr/dataclay/dataclay.jar $SCRIPTDIR/javaclay/dataclay.jar
mkdir -p $SCRIPTDIR/javaclay/aspectj/
singularity exec $DATACLAY_HOME/singularity/images/logicmodule.sif \
	cp /usr/share/java/aspectjrt.jar $SCRIPTDIR/javaclay/aspectj/
singularity exec $DATACLAY_HOME/singularity/images/logicmodule.sif \
	cp /usr/share/java/aspectjweaver.jar $SCRIPTDIR/javaclay/aspectj/
singularity exec $DATACLAY_HOME/singularity/images/logicmodule.sif \
	cp /usr/share/java/aspectjtools.jar $SCRIPTDIR/javaclay/aspectj/
	
echo "Installing pyclay..."
pyclay3.6
pip install dataclay <= login0? 
pyclay3.7
pyclay3.8
PYCLAY_SRC=

if [ -z $EXTRAE_HOME ]; then 
	echo "WARNING: EXTRAE_HOME not set. To install extrae necessary libraries for pyClay, make sure extrae is installed. "
else
	echo "Using Extrae installed at $EXTRAE_HOME"
	DATACLAY_EXTRAE_WRAPPER_LIB=$SCRIPTDIR/pyclay/pyextrae/dataclay_extrae_wrapper.so
	echo "Installing pyclay-extrae..."
	singularity exec $DATACLAY_HOME/singularity/images/dspython.sif \
		cp -r /home/dataclayusr/dataclay/pyextrae $SCRIPTDIR/pyclay/
	
	# Compile dataClay extrae wrapper
	pushd $SCRIPTDIR/pyclay/pyextrae 
	gcc -L${EXTRAE_HOME}/lib -I${EXTRAE_HOME}/include extrae_wrapper.c \
		-lpttrace -fPIC --shared -o ${DATACLAY_EXTRAE_WRAPPER_LIB}
	
	# Copy extrae configurations 
	singularity exec $DATACLAY_HOME/singularity/images/dspython.sif \
		cp /home/dataclayusr/dataclay/extrae/extrae_python.xml $SCRIPTDIR/pyclay/pyextrae
	popd
fi