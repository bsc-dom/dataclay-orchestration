# Extrae

To generate .so files in MareNostrum:

Load extrae:
```bash
module load extrae
```

Compile javaextrae:
```bash
cd javaextrae && \
    gcc -fPIC \
    -I${JAVA_HOME}/include \
    -I${JAVA_HOME}/include/linux \
    -I${EXTRAE_HOME}/include \
    -I. \
    es_bsc_dataclay_extrae_Wrapper.c \
    --shared \
    -o javaclay_extrae_wrapper.so
```

Compile pyextrae:
```bash
cd pyextrae && \
    gcc -fPIC \
    -L${EXTRAE_HOME}/lib \
    -I${EXTRAE_HOME}/include \
    extrae_wrapper.c \
    -lpttrace \
    --shared \
    -o pyclay_extrae_wrapper.so
```