#!/bin/bash

set -e
set -o pipefail
set -x


HT_VERSION=master
NCURSES_VERSION=5.9


function build_ncurses() {
    cd /build

    # Download
    curl -LO http://invisible-island.net/datafiles/release/ncurses.tar.gz
    tar zxvf ncurses.tar.gz
    cd ncurses-${NCURSES_VERSION}

    # Build
    CC='/opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-gcc -static' \
        CXX='/opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-g++ -static' \
        AR='/opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-ar' \
        CFLAGS='-fPIC' \
        CXXFLAGS='-fPIC' \
        ./configure \
        --disable-shared \
        --enable-static
    make

    ln -s /build/ncurses-${NCURSES_VERSION}/lib/libncurses.a /build/ncurses-${NCURSES_VERSION}/lib/libcurses.a
}

function build_ht() {
    cd /build

    # Download
    git clone --branch ${HT_VERSION} https://github.com/sebastianbiallas/ht.git
    cd ht

    # Autoconf stuff
    ./autogen.sh

    # Build
    CC='/opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-gcc -static' \
        CXX='/opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-g++ -static' \
        AR='/opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-ar' \
        CFLAGS='-fPIC' \
        CXXFLAGS='-fPIC' \
        CPPFLAGS="-I/build -I/build/ncurses-${NCURSES_VERSION}/include" \
        LDFLAGS="-L/build/ncurses-${NCURSES_VERSION}/lib" \
        ./configure \
        --enable-release

    make || true
    make htdoc.h
    make

    strip ht
}

function doit() {
    build_ncurses
    build_ht

    # Copy to output
    if [ -d /output ]
    then
        OUT_DIR=/output/`uname | tr 'A-Z' 'a-z'`/`uname -m`
        mkdir -p $OUT_DIR
        cp /build/ht/ht $OUT_DIR/
        echo "** Finished **"
    else
        echo "** /output does not exist **"
    fi
}

doit
