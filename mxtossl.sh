#!/bin/bash

# Mindestanforderungen
REQUIRED_AR="2.38"
REQUIRED_PERL="5.32"
REQUIRED_MAKE="4.1"
REQUIRED_GCC="4.9"

# Versionsvergleich ohne sort -V
version_ge() {
    cur_version=$1
    req_version=$2

    cur_major=$(echo "$cur_version" | cut -d. -f1)
    cur_minor=$(echo "$cur_version" | cut -d. -f2)
    req_major=$(echo "$req_version" | cut -d. -f1)
    req_minor=$(echo "$req_version" | cut -d. -f2)

    # Default auf 0, falls z. B. nur "5" geliefert wird
    cur_major=${cur_major:-0}
    cur_minor=${cur_minor:-0}
    req_major=${req_major:-0}
    req_minor=${req_minor:-0}

    if [ "$cur_major" -gt "$req_major" ]; then
        return 0
    elif [ "$cur_major" -lt "$req_major" ]; then
        return 1
    else
        [ "$cur_minor" -ge "$req_minor" ] && return 0 || return 1
    fi
}

# Generischer Check für ein Tool
check_tool() {
    name=$1
    cmd=$2
    required=$3
    version_cmd=$4

    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "❌ '$name' ist nicht installiert oder nicht im PATH."
        return 1
    fi

    raw_version=$(eval "$version_cmd" 2>/dev/null | sed -n 's/.*\([0-9][0-9]*\.[0-9][0-9]*\).*/\1/p' | head -n1)

    if version_ge "$raw_version" "$required"; then
        echo "✅ $name-Version OK ($raw_version ≥ $required)"
        return 0
    else
        echo "❌ $name-Version zu alt ($raw_version < $required)"
        return 1
    fi
}

### Einzelne Checks
check_tool "ar"   "ar"   "$REQUIRED_AR"   "ar --version"
check_tool "perl" "perl" "$REQUIRED_PERL" "perl -e 'print \$];'"
check_tool "make" "make" "$REQUIRED_MAKE" "make --version"
check_tool "gcc"  "gcc"  "$REQUIRED_GCC"  "gcc --version"

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