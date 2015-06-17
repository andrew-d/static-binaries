#!/bin/bash

set -e
set -o pipefail
set -x


FILE_VERSION=5.23

# Set up path
export PATH=$PATH:/opt/cross/arm-linux-musleabihf/bin/


function build_file() {
    cd /build

    # Download
    curl -LO ftp://ftp.astron.com/pub/file/file-${FILE_VERSION}.tar.gz
    tar xzvf file-${FILE_VERSION}.tar.gz
    cd file-${FILE_VERSION}

    # Don't run tests.
    printf "all:\n\ttrue\n\ninstall:\n\ttrue\n\n" > tests/Makefile.in

    # Fix header files
    sed -i 's/memory.h/string.h/' src/encoding.c src/ascmagic.c

    # Firstly, compile natively.
    ./configure --disable-shared
    make -j4

    # Copy the generated binary to our build dir
    cp ./src/file /build/file

    # Clean up
    make distclean || true

    # Configure for cross-compiling
    CC='arm-linux-musleabihf-gcc -Wl,-static -static-libgcc -static -frandom-seed=build-file-arm -D_GNU_SOURCE -D_BSD_SOURCE' \
        ./configure \
            --disable-shared \
            --host=$(arm-linux-musleabihf-gcc -dumpmachine | sed 's/musl/gnu/') \
            --build=i686

    # Use the native version of file to compile our magic file.
    sed -i 's|FILE_COMPILE = file${EXEEXT}|FILE_COMPILE = /build/file|' ./magic/Makefile

    # Build the cross-compiled version.
    make
    arm-linux-musleabihf-strip ./src/file
}


function doit() {
    build_file

    # Copy to output
    if [ -d /output ]
    then
        OUT_DIR=/output/`uname | tr 'A-Z' 'a-z'`/arm
        mkdir -p $OUT_DIR
        cp /build/file-${FILE_VERSION}/src/file $OUT_DIR/
        echo "** Finished **"
    else
        echo "** /output does not exist **"
    fi
}

doit
