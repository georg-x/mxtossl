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
    # https://docs.google.com/presentation/d/1_io0pYZAp-x_jJqJ6uE1kZvEtJ25rtshwPaR0xw2ehc/edit#slide=id.g2ef1e97c324_0_0
    # libcrypto - smaller by 33%
    # libssl - smaller by 42%
    # enable-ec_nistp_64_gcc_128 no-argon2 no-aria no-async no-bf no-blake2 no-camellia no-cast no-cmp no-cms no-comp no-deprecated no-des no-dgram no-dh no-dsa no-ec2m no-engine no-gost no-http no-idea no-legacy no-md4 no-mdc2 no-multiblock no-nextprotoneg no-ocb no-ocsp no-quic no-rc2 no-rc4 no-rmd160 no-scrypt no-seed no-siphash no-siv no-sm2 no-sm3 no-sm4 no-srp no-srtp no-ts no-whirlpool -Os
    # enable-ec_nistp_64_gcc_128 Option nicht für Mobaxterm verfügbar, weil kein 128 Bit Datentype verfügbar ist
    ./config no-argon2 no-aria no-async no-bf no-blake2 no-camellia no-cast no-cmp no-cms no-comp no-deprecated no-des no-dgram no-dh no-dsa no-ec2m no-engine no-gost no-http no-idea no-legacy no-md4 no-mdc2 no-multiblock no-nextprotoneg no-ocb no-ocsp no-quic no-rc2 no-rc4 no-rmd160 no-scrypt no-seed no-siphash no-siv no-sm2 no-sm3 no-sm4 no-srp no-srtp no-ts no-whirlpool -Os

    make
 
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
