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
    export PATH=$PATH:/opt/cross/x86_64-linux-musl/bin/

    # Build
    CC='x86_64-linux-musl-gcc -static -fPIC' \
        ./configure --host=x86_64-linux
    make
    x86_64-linux-musl-strip strace
}

function doit() {
    build_strace

    # Copy to output
    if [ -d /output ]
    then
        OUT_DIR=/output/`uname | tr 'A-Z' 'a-z'`/x86_64
        mkdir -p $OUT_DIR
        cp /build/strace-${STRACE_VERSION}/strace $OUT_DIR/
        echo "** Finished **"
    else
        echo "** /output does not exist **"
    fi
}

doit
