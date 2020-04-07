#!/bin/bash
singularity exec $DATACLAY_HOME/images/logicmodule.sif cp /home/dataclayusr/dataclay/dataclay.jar $DATACLAY_HOME/javaclay
singularity exec $DATACLAY_HOME/images/dspython.sif cp -r /home/dataclayusr/dataclay/dataclay_venv/* $DATACLAY_HOME/pyclay/
