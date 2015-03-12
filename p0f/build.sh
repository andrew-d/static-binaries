#!/bin/bash

set -e
set -o pipefail
set -x


LIBPCAP_VERSION=1.7.2
P0F_VERSION=3.08b


function build_libpcap() {
    cd /build

    # Install required dependencies
    DEBIAN_FRONTEND=noninteractive apt-get install -yy flex bison

    # Download
    curl -LO http://www.tcpdump.org/release/libpcap-${LIBPCAP_VERSION}.tar.gz
    tar xzvf libpcap-${LIBPCAP_VERSION}.tar.gz
    cd libpcap-${LIBPCAP_VERSION}

    # Build
    CC='/opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-gcc -static -fPIC' \
        LD=/opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-ld \
        ./configure --disable-shared
    make -j4
}

function build_p0f() {
    cd /build

    # Download
    curl -LO http://lcamtuf.coredump.cx/p0f3/releases/p0f-${P0F_VERSION}.tgz
    tar xzvf p0f-${P0F_VERSION}.tgz
    cd p0f-${P0F_VERSION}

    # Build
    CC='/opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-gcc -static -fPIC' \
        CFLAGS="-I/build/libpcap-${LIBPCAP_VERSION}/pcap -I/build/libpcap-${LIBPCAP_VERSION}" \
        LDFLAGS="-L/build/libpcap-${LIBPCAP_VERSION}" \
        make

    /opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-strip p0f
}

function doit() {
    build_libpcap
    build_p0f

    # Copy to output
    if [ -d /output ]
    then
        OUT_DIR=/output/`uname | tr 'A-Z' 'a-z'`/`uname -m`
        mkdir -p $OUT_DIR
        cp /build/p0f-${P0F_VERSION}/p0f $OUT_DIR/
        echo "** Finished **"
    else
        echo "** /output does not exist **"
    fi
}

doit
