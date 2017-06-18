#!/bin/bash

set -e
set -o pipefail
set -x


BUILD_DIR=/build
OUTPUT_DIR=/output

MUSL_VERSION=1.1.16
NANO_VERSION=2.8.4
NCURSES_VERSION=5.9


function build_musl() {
    cd ${BUILD_DIR}

    # Download
    curl -LO http://www.musl-libc.org/releases/musl-${MUSL_VERSION}.tar.gz
    tar zxvf musl-${MUSL_VERSION}.tar.gz
    cd musl-${MUSL_VERSION}

    # Build
    ./configure
    make -j4
    make install
}

function build_ncurses() {
    cd ${BUILD_DIR}

    # Download
    curl -LO http://invisible-island.net/datafiles/release/ncurses.tar.gz
    tar zxvf ncurses.tar.gz
    cd ncurses-${NCURSES_VERSION}

    # Build
    CC='/usr/local/musl/bin/musl-gcc -static' CFLAGS='-fPIC' ./configure \
        --prefix=/usr \
        --disable-shared \
        --enable-static \
        --with-normal \
        --without-debug \
        --without-ada \
        --with-default-terminfo=/usr/share/terminfo \
        --with-terminfo-dirs="/etc/terminfo:/lib/terminfo:/usr/share/terminfo:/usr/lib/terminfo"

    mkdir "${BUILD_DIR}/ncurses-install"
    make DESTDIR="${BUILD_DIR}/ncurses-install" \
        install.libs install.includes
}

function build_nano() {
    cd ${BUILD_DIR}

    # Download
    curl -LO https://www.nano-editor.org/dist/v${NANO_VERSION%.*}/nano-${NANO_VERSION}.tar.xz
    tar xJvf nano-${NANO_VERSION}.tar.xz
    cd nano-${NANO_VERSION}

    CC='/usr/local/musl/bin/musl-gcc -static' \
    CFLAGS="-fPIC" \
    CPPFLAGS="-I${BUILD_DIR}/ncurses-install/usr/include" \
    LDFLAGS="-L${BUILD_DIR}/ncurses-install/usr/lib" \
        ./configure \
            --disable-nls \
            --disable-dependency-tracking

    make -j4
    strip src/nano
}

function doit() {
    build_musl
    build_ncurses
    build_nano

    # Copy to output
    if [ -d ${OUTPUT_DIR} ]
    then
        OUT_DIR=${OUTPUT_DIR}/`uname | tr 'A-Z' 'a-z'`/`uname -m`
        mkdir -p $OUT_DIR
        cp ${BUILD_DIR}/nano-${NANO_VERSION}/src/nano $OUT_DIR/
        echo "** Finished **"
    else
        echo "** ${OUTPUT_DIR} does not exist **"
    fi
}

doit
