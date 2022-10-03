-- Information
whatis("Version: DevelMarc[2.7.dev]")
whatis("Keywords: Storage, dataClay, data distribution")
whatis("Description: dataClay active objects across the network")

-- lua mod file for dataClay
PROG_NAME = "DATACLAY"
PROG_VERSION = "DevelMarc"
PROG_HOME = "/apps/" .. PROG_NAME .. "/" .. PROG_VERSION
DATACLAY_HOME = PROG_HOME

-- Dependencies
-- SINGULARITY_VERSION = "3.5.2"
PYTHON_VERSION = "3.10"
PYTHON_FULL_VERSION = "3.10.2"
GCC_VERSION = "8.1.0"
EXTRAE_VERSION = "4.0.0"

-- Module dependencies
load("gcc/" .. GCC_VERSION)
if (not isloaded("python")) then load("python/" .. PYTHON_FULL_VERSION) end
if (not isloaded("EXTRAE")) then load("EXTRAE/" .. EXTRAE_VERSION) end

prereq(atleast("python","3.6.1"))
-- load("singularity/" .. SINGULARITY_VERSION) 

-- Bind into dataClay containers
-- add here colon sepparated folders to bind into singularity containers. 
-- /usr/lib64 is used by INTEL python
setenv("DATACLAY_EXT_BIND", "/usr/lib64")

-- DATACLAY binaries
append_path("PATH", DATACLAY_HOME .. "/bin")
setenv("DATACLAY_HOME", DATACLAY_HOME)

-- setenv("STORAGE_METADATA_PATH", "/scratch/tmp/dataclay_metadata") -- ALEX

-- For apps outside containers

-- javaclay
setenv("DATACLAY_JAR", DATACLAY_HOME .. "/javaclay/dataclay.jar")

-- pyclay
execute {cmd="export PYCLAY_PATH=$DATACLAY_HOME/pyclay/src:$DATACLAY_HOME/dataclay-common/src/python:$DATACLAY_HOME/metadata-service/src:$(find /apps/DATACLAY/DevelMarc/dependencies/pyenv$(python --version | awk '{print $2}')* -name site-packages)",modeA={"load"}}
execute {cmd="export PYTHONPATH=$PYCLAY_PATH:$PYTHONPATH", modeA={"load"}}
execute {cmd="export PATH=$PATH:$(find /apps/DATACLAY/DevelMarc/dependencies/pyenv$(python --version | awk '{print $2}')* -name bin)", modeA={"load"}}


-- COMPSs bindings
-- append_path("PATH", DATACLAY_HOME .. "/scripts")
setenv("COMPSS_STORAGE_HOME", DATACLAY_HOME)



