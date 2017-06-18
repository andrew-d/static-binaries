#!/bin/bash

set -e
set -o pipefail
set -x


MUSL_VERSION=1.1.16
ZLIB_VERSION=1.2.11
PCRE_VERSION=8.40
LZMA_VERSION=5.2.3
AG_VERSION=master


function build_musl() {
    cd /build

    # Download
    curl -LO http://www.musl-libc.org/releases/musl-${MUSL_VERSION}.tar.gz
    tar zxvf musl-${MUSL_VERSION}.tar.gz
    cd musl-${MUSL_VERSION}

    # Build
    ./configure
    make -j4
    make install
}

function build_zlib() {
    cd /build

    # Download
    curl -LO http://zlib.net/zlib-${ZLIB_VERSION}.tar.gz
    tar zxvf zlib-${ZLIB_VERSION}.tar.gz
    cd zlib-${ZLIB_VERSION}

    # Build
    CC='/usr/local/musl/bin/musl-gcc -static' CFLAGS='-fPIC' ./configure \
        --static
    make -j4
}

function build_pcre() {
    cd /build

    # Download
    curl -LO ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-${PCRE_VERSION}.tar.gz
    tar zxvf pcre-${PCRE_VERSION}.tar.gz
    cd pcre-${PCRE_VERSION}

    # Build
    CC='/usr/local/musl/bin/musl-gcc -static' CFLAGS='-fPIC' ./configure \
        --disable-shared \
        --enable-static
    make -j4
}

function build_lzma() {
    cd /build

    # Download
    curl -LO http://tukaani.org/xz/xz-${LZMA_VERSION}.tar.gz
    tar zxvf xz-${LZMA_VERSION}.tar.gz
    cd xz-${LZMA_VERSION}

    # Build
    CC='/usr/local/musl/bin/musl-gcc -static' CFLAGS='-fPIC' ./configure \
        --disable-shared \
        --enable-static
    make -j4
}

function build_ag() {
    cd /build

    # Clone
    git clone -b ${AG_VERSION} https://github.com/ggreer/the_silver_searcher.git
    cd the_silver_searcher

    # Autoconf
    aclocal
    autoconf
    autoheader
    automake --add-missing

    # Configure
    # Note: since the system won't have PCRE/liblzma installed, we just have pkg-config return true
    CC='/usr/local/musl/bin/musl-gcc -static'                               \
        CFLAGS='-fPIC'                                                      \
        CPPFLAGS="-I/build/pcre-${PCRE_VERSION} -I/build/xz-${LZMA_VERSION}/src/liblzma/api -I/build/zlib-${ZLIB_VERSION}" \
        LDFLAGS="-L/build/zlib-${ZLIB_VERSION} -lz"    \
        PCRE_LIBS="-L/build/pcre-${PCRE_VERSION}/.libs -lpcre"              \
        PCRE_CFLAGS="-I/build/pcre-${PCRE_VERSION}"                         \
        LZMA_LIBS="-L/build/xz-${LZMA_VERSION}/src/liblzma/.libs -llzma"    \
        LZMA_CFLAGS="-I/build/xz-${LZMA_VERSION}/src/liblzma/api"           \
        ZLIB_LIBS="-L/build/zlib-${ZLIB_VERSION} -lz"    \
        ZLIB_CFLAGS="-I/build/zlib-${ZLIB_VERSION}"           \
        ./configure PKG_CONFIG="/bin/true"

    # Build
    make -j4
    strip ag
}

function doit() {
    # Kick off all builds
    build_musl
    build_zlib
    build_pcre
    build_lzma
    build_ag

    # Copy ag to output
    if [ -d /output ]
    then
        OUT_DIR=/output/`uname | tr 'A-Z' 'a-z'`/`uname -m`
        mkdir -p $OUT_DIR
        cp /build/the_silver_searcher/ag $OUT_DIR/
        echo "** Finished **"
    else
        echo "** /output does not exist **"
    fi
}

doit
