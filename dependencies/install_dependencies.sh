#!/bin/bash 
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"


function install_deps {
    PYVER=$1
    MODULE_NAME="python/$PYVER"
    module --force purge
    if [ "$#" -gt 1 ]; then
        MODULE_DEPS=$2
        module load $MODULE_DEPS
    fi
    module load "$MODULE_NAME"

    echo " ************** INSTALLING DEPENDENCIES FOR PYTHON $PYVER **************** "
    echo "Creating virtual environment for python \"$PYVER\""
    rm -rf $SCRIPTDIR/pyenv$PYVER #sanity check 
    python -m venv $SCRIPTDIR/pyenv$PYVER
    echo "Installing dataClay dependencies:"
    cat $SCRIPTDIR/requirements.txt 
    source $SCRIPTDIR/pyenv$PYVER/bin/activate 
    python -m pip install --upgrade pip
    python -m pip install --upgrade setuptools
    python -m pip install -r $SCRIPTDIR/requirements.txt
    deactivate
    
}

### Install dataClay dependencies ###
# install_deps 3.6.4_ML "gcc/8.1.0 impi/2018.1 mkl/2018.1 opencv/4.1.2"
install_deps 3.10.2 "mkl intel"

# Install extrae wrappers
# $SCRIPTDIR/extrae_wrapper/install_dataclay_wrappers.sh
