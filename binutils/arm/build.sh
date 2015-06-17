#!/bin/bash

set -e
set -o pipefail
set -x


BINUTILS_VERSION=2.25


export PATH=$PATH:/opt/cross/arm-linux-musleabihf/bin/


function build_binutils() {
    cd /build

    # Install dependencies
    DEBIAN_FRONTEND=noninteractive apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -yy texinfo file

    # Download
    curl -LO http://ftp.gnu.org/gnu/binutils/binutils-${BINUTILS_VERSION}.tar.gz
    tar xzvf binutils-${BINUTILS_VERSION}.tar.gz

    # Make build directory
    mkdir binutils-build
    cd binutils-build

    # Figure out which config options to use.  This was borrowed from:
    #   https://github.com/jelaas/bifrost-build/blob/5df15f90231bdf2f9567b71df4422576334ebe05/all/binutils-2.22-1/B-configure
    TMPFILE=`pwd`/configure.output
    ../binutils-${BINUTILS_VERSION}/configure --help > $TMPFILE

    CONFIGURE_OPTS=""
    for opt in disable-nls enable-static-link disable-shared-plugins disable-dynamicplugin disable-tls disable-pie; do
        grep -qs $opt $TMPFILE && CONFIGURE_OPTS="$CONFIGURE_OPTS --$opt"
    done
    for opt in enable-static; do
        grep -qs $opt $TMPFILE && CONFIGURE_OPTS="$CONFIGURE_OPTS --$opt=yes"
    done
    for opt in enable-shared; do
        grep -qs $opt $TMPFILE && CONFIGURE_OPTS="$CONFIGURE_OPTS --$opt=no"
    done
    rm -f $TMPFILE

    # Configure
    CC='arm-linux-musleabihf-gcc -static -fPIC -frandom-seed=build-binutils-arm' \
        CXX='arm-linux-musleabihf-g++ -static -static-libstdc++ -fPIC -frandom-seed=build-binutils-arm' \
        LD=arm-linux-musleabihf-ld \
        ../binutils-${BINUTILS_VERSION}/configure \
            --target= \
            --build=i686 \
            --host=arm-linux-musleabihf \
            --prefix=`pwd` \
            ${CONFIGURE_OPTS}

    # This strange dance is required to get things to be statically linked.
    make
    make clean
    make LDFLAGS=-all-static

    # Strip outputs
    OUTPUT_FILES="ar nm-new objcopy objdump ranlib readelf size strings"
    for f in ${OUTPUT_FILES};
    do
        arm-linux-musleabihf-strip binutils/$f
    done
    arm-linux-musleabihf-strip ld/ld-new
}

function doit() {
    build_binutils

    # Copy to output
    if [ -d /output ]
    then
        OUT_DIR=/output/`uname | tr 'A-Z' 'a-z'`/arm
        mkdir -p $OUT_DIR

        for f in ar objcopy objdump ranlib readelf size strings;
        do
            cp /build/binutils-build/binutils/$f $OUT_DIR/
        done
        cp /build/binutils-build/binutils/nm-new $OUT_DIR/nm
        cp /build/binutils-build/ld/ld-new $OUT_DIR/ld

        echo "** Finished **"
    else
        echo "** /output does not exist **"
    fi
}

doit
