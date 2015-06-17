#!/bin/bash

set -e
set -o pipefail
set -x


LIBPCAP_VERSION=1.7.3
TCPDUMP_VERSION=4.7.4


# Set up path
export PATH=$PATH:/opt/cross/arm-linux-musleabihf/bin/


function build_libnl_tiny() {
    cd /build

    # Download
    git clone https://github.com/sabotage-linux/libnl-tiny.git
    cd libnl-tiny

    # Build
    make ALL_LIBS=libnl-tiny.a \
         CC='/opt/cross/arm-linux-musleabihf/bin/arm-linux-musleabihf-gcc -frandom-seed=build-libnl-tiny-arm' \
         CFLAGS=-static all
}


function build_libpcap() {
    cd /build

    # Install dependencies
    DEBIAN_FRONTEND=noninteractive apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -yy bison flex

    # Download
    curl -LO http://www.tcpdump.org/release/libpcap-${LIBPCAP_VERSION}.tar.gz
    tar xzvf libpcap-${LIBPCAP_VERSION}.tar.gz
    cd libpcap-${LIBPCAP_VERSION}

    # Build
    CC='arm-linux-musleabihf-gcc -static -frandom-seed=build-libpcap-arm' \
        CFLAGS='-D_GNU_SOURCE -D_BSD_SOURCE -DIPPROTO_HOPOPTS=0 -I/build/libnl-tiny' \
        ./configure \
        --disable-canusb \
        --host=$(arm-linux-musleabihf-gcc -dumpmachine|sed 's/musl/gnu/') \
        --with-pcap=linux
        ac_cv_type_u_int64_t=yes \
    make
}


function build_tcpdump() {
    cd /build

    # Download
    curl -LO http://www.tcpdump.org/release/tcpdump-4.7.4.tar.gz
    tar xzvf tcpdump-${TCPDUMP_VERSION}.tar.gz
    cd tcpdump-${TCPDUMP_VERSION}

    # Build
    CC='arm-linux-musleabihf-gcc -static -frandom-seed=build-tcpdump-arm' \
        CPPFLAGS='-D_GNU_SOURCE -D_BSD_SOURCE' \
        LDFLAGS="-static -L/build/libnl-tiny -L/build/libpcap-${LIBPCAP_VERSION}" \
        LIBS='-lpcap -lnl-tiny' \
        ./configure \
        --without-crypto \
        --host=$(arm-linux-musleabihf-gcc -dumpmachine | sed 's/musl/gnu/') \
        ac_cv_linux_vers=3

    make
    arm-linux-musleabihf-strip tcpdump
}

function doit() {
    build_libnl_tiny
    build_libpcap
    build_tcpdump

    # Copy to output
    if [ -d /output ]
    then
        OUT_DIR=/output/`uname | tr 'A-Z' 'a-z'`/arm
        mkdir -p $OUT_DIR
        cp /build/tcpdump-${TCPDUMP_VERSION}/tcpdump $OUT_DIR/
        echo "** Finished **"
    else
        echo "** /output does not exist **"
    fi
}

doit

