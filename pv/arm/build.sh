#!/bin/bash

set -e
set -o pipefail
set -x


PV_VERSION=1.6.0


function build_pv() {
    cd /build

    # Download
    curl -LO https://www.ivarch.com/programs/sources/pv-${PV_VERSION}.tar.bz2
    tar xjvf pv-${PV_VERSION}.tar.bz2
    cd pv-${PV_VERSION}

    # Set up path
    export PATH=$PATH:/opt/cross/arm-linux-musleabihf/bin/

    # Configure
    CFLAGS='-static -frandom-seed=build-pv-arm' \
        ./configure --build=i686 --host=arm-linux-musleabihf

    # Fix the linker (ld)
    sed -i '/^CC =/a LD = arm-linux-musleabihf-ld' Makefile

    # Build
    make
    /opt/cross/arm-linux-musleabihf/bin/arm-linux-musleabihf-strip pv
}

function doit() {
    build_pv

    # Copy to output
    if [ -d /output ]
    then
        OUT_DIR=/output/`uname | tr 'A-Z' 'a-z'`/arm
        mkdir -p $OUT_DIR
        cp /build/pv-${PV_VERSION}/pv $OUT_DIR/
        echo "** Finished **"
    else
        echo "** /output does not exist **"
    fi
}

doit
