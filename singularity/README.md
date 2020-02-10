Scripts to deploy dataClay through singularity-compose.


```
.
├── scripts 
│   ├── dataclay_start.sh : start dataclay through singularity-compose
│   ├── dataclay_stop.sh : gracefully stop dataclay through singularity-compose
│   ├── clean.sh : clean dataclay logs and files
├── default_env.sh : machine-dependene default environment variables
├── prepare_env.sh : prepare scripts to set jobs' environment variables
├── singularity-compose-templates: needed to generate singularity-compose files
└── images: singularity images
    ├── dsjava.sif
    ├── dspython.sif
    └── logicmodule.sif
    └── Singularity: empty file needed for singularity-compose deployment
```
