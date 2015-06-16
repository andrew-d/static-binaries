#!/bin/bash

set -e
set -o pipefail
set -x


YASM_VERSION=master


function build_yasm() {
    cd /build

    # Install dependencies
    DEBIAN_FRONTEND=noninteractive apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -yy python

    # Download
    git clone --branch ${YASM_VERSION} https://github.com/yasm/yasm.git
    cd yasm

    # Configure
    CC='/opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-gcc -static -fPIC' \
        CXX='/opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-g++ -static -static-libstdc++ -fPIC' \
        LD=/opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-ld \
        ./autogen.sh \
            --disable-nls

    # Build
    make -j4
    /opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-strip yasm vsyasm ytasm
}

function doit() {
    build_yasm

    # Copy to output
    if [ -d /output ]
    then
        OUT_DIR=/output/`uname | tr 'A-Z' 'a-z'`/`uname -m`
        mkdir -p $OUT_DIR
        cp yasm vsyasm ytasm $OUT_DIR/
        echo "** Finished **"
    else
        echo "** /output does not exist **"
    fi
}

doit
