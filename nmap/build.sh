#!/bin/bash

set -e
set -o pipefail
set -x


NMAP_VERSION=6.49BETA1
OPENSSL_VERSION=1.0.2c


function build_openssl() {
    cd /build

    # Download
    curl -LO https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz
    tar zxvf openssl-${OPENSSL_VERSION}.tar.gz
    cd openssl-${OPENSSL_VERSION}

    # Configure
    CC='/opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-gcc -static' ./Configure no-shared linux-x86_64

    # Build
    make
    echo "** Finished building OpenSSL"
}

function build_nmap() {
    cd /build

    # Install Python
    DEBIAN_FRONTEND=noninteractive apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -yy python

    # Download
    curl -LO http://nmap.org/dist/nmap-${NMAP_VERSION}.tar.bz2
    tar xjvf nmap-${NMAP_VERSION}.tar.bz2
    cd nmap-${NMAP_VERSION}

    # Configure
    CC='/opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-gcc -static -fPIC' \
        CXX='/opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-g++ -static -static-libstdc++ -fPIC' \
        LD=/opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-ld \
        LDFLAGS="-L/build/openssl-${OPENSSL_VERSION}"   \
        ./configure \
            --without-ndiff \
            --without-zenmap \
            --without-nmap-update \
            --with-pcap=linux \
            --with-openssl=/build/openssl-${OPENSSL_VERSION}

    # Don't build the libpcap.so file
    sed -i -e 's/shared\: /shared\: #/' libpcap/Makefile

    # Build
    make -j4
    /opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-strip nmap ncat/ncat nping/nping
}

function doit() {
    build_openssl
    build_nmap

    # Copy to output
    if [ -d /output ]
    then
        OUT_DIR=/output/`uname | tr 'A-Z' 'a-z'`/`uname -m`
        mkdir -p $OUT_DIR
        cp /build/nmap-${NMAP_VERSION}/nmap $OUT_DIR/
        cp /build/nmap-${NMAP_VERSION}/ncat/ncat $OUT_DIR/
        cp /build/nmap-${NMAP_VERSION}/nping/nping $OUT_DIR/
        echo "** Finished **"
    else
        echo "** /output does not exist **"
    fi
}

doit
