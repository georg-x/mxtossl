#!/bin/bash

# Suche openssl*.tar.gz Files
ls -1 *.tar.gz | while read LINE; do 
    echo $LINE
    #openssl-3.5.0-beta1.tar.gz
    XPATH=${LINE%%.tar.gz}
    VERSION=${XPATH##openssl-}
    rm -rf $XPATH
    tar -xzf $LINE
    cd $XPATH
    ./config
    make
    
done

# Entpacke alle diese Files
# config
# make
# teste das binary
# erzeuge mit zip eine mxt3 datei
# erzeuge den html code für eine download übersicht