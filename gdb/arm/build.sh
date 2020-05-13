#!/bin/bash

set -e
set -o pipefail
set -x


GDB_VERSION=8.2


function build_strace() {
    cd /build

    # Download
    curl -LO ftp://sourceware.org/pub/gdb/releases/gdb-${GDB_VERSION}.tar.xz
    tar xvf gdb-${GDB_VERSION}.tar.xz
    cd gdb-${GDB_VERSION}

    # Set up path
    export PATH=$PATH:/opt/cross/arm-linux-musleabihf/bin/

    # Build
	./configure --host=arm-linux-musleabihf --enable-static=yes CXXFLAGS="-fPIC -static" CFLAGS="-fPIC -static" LDFLAGS="-static"
	make -j $(grep ^processor /proc/cpuinfo | wc -l)
    arm-linux-musleabihf-strip gdb/gdb
	arm-linux-musleabihf-strip gdb/gdbserver/gdbserver
}

function doit() {
    build_strace

    # Copy to output
    if [ -d /output ]
    then
        OUT_DIR=/output/`uname | tr 'A-Z' 'a-z'`/arm
        mkdir -p $OUT_DIR
        cp /build/gdb-${GDB_VERSION}/gdb/gdb $OUT_DIR/
        cp /build/gdb-${GDB_VERSION}/gdb/gdbserver/gdbserver $OUT_DIR/
        echo "** Finished **"
    else
        echo "** /output does not exist **"
    fi
}

doit
