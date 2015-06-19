#!/bin/bash

set -e
set -o pipefail
set -x


XXD_VERSION=1.10


function build_xxd() {
    cd /build

    mkdir xxd-${XXD_VERSION}
    mv xxd.c xxd-${XXD_VERSION}/
    cd xxd-${XXD_VERSION}

    arm-linux-musleabihf-gcc \
        -static \
        -frandom-seed=build-xxd-arm \
        -O3 \
        -DUNIX \
        -o xxd \
        xxd.c
    arm-linux-musleabihf-strip xxd
}

function doit() {
    build_xxd

    # Copy to output
    if [ -d /output ]
    then
        OUT_DIR=/output/`uname | tr 'A-Z' 'a-z'`/arm
        mkdir -p $OUT_DIR
        cp /build/xxd-${XXD_VERSION}/xxd $OUT_DIR/
        echo "** Finished **"
    else
        echo "** /output does not exist **"
    fi
}

doit
