#!/bin/bash

set -e
set -o pipefail
set -x


STRACE_VERSION=4.10


function build_strace() {
    cd /build

    # Download
    curl -LO http://downloads.sourceforge.net/project/strace/strace/${STRACE_VERSION}/strace-${STRACE_VERSION}.tar.xz
    tar xJvf strace-${STRACE_VERSION}.tar.xz
    cd strace-${STRACE_VERSION}

    # Add missing headers.
    patch -p2 < /build/strace.patch

    # Set up path
    export PATH=$PATH:/opt/cross/arm-linux-musleabihf/bin/

    # Build
    CC='arm-linux-musleabihf-gcc -static -frandom-seed=build-strace-arm' \
        ./configure --host=arm-linux
    make
    arm-linux-musleabihf-strip strace
}

function doit() {
    build_strace

    # Copy to output
    if [ -d /output ]
    then
        OUT_DIR=/output/`uname | tr 'A-Z' 'a-z'`/arm
        mkdir -p $OUT_DIR
        cp /build/strace-${STRACE_VERSION}/strace $OUT_DIR/
        echo "** Finished **"
    else
        echo "** /output does not exist **"
    fi
}

doit
