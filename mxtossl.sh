#!/bin/bash

# Todo: check for prerequisites ... make / ar?

# Suche openssl*.tar.gz Files
ls -1 *.tar.gz | while read LINE; do 
    echo $LINE
    #LINE=openssl-3.5.0-beta1.tar.gz
    XPATH=${LINE%%.tar.gz}
    VERSION=${XPATH##openssl-}
    rm -rf $XPATH
    tar -xzf $LINE
    cd $XPATH
    ./config
    make
    cd $XPATH
    # teste binary
    cd apps
    ./openssl.exe version
    mkdir bin
    cp -a openssl.exe bin/openssl3.exe
    cp cygcrypto-3.dll bin
    cp cygssl-3.dll bin
    zip ${XPATH}.mxt3 bin/*
    mv ${XPATH}.mxt3 ../../
done 

# Entpacke alle diese Files
# config
# make
# teste das binary
# erzeuge mit zip eine mxt3 datei
# erzeuge den html code für eine download übersicht