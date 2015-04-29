#!/bin/bash

set -e
set -o pipefail
set -x


SOCAT_VERSION=1.7.3.0
NCURSES_VERSION=5.9
READLINE_VERSION=6.3
OPENSSL_VERSION=1.0.2a

OUR_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
ROOT_DIR=`mktemp -d /tmp/socat-build.XXXXXX` || exit 1


function build_ncurses() {
    cd ${ROOT_DIR}

    # Download
    curl -LO http://invisible-island.net/datafiles/release/ncurses.tar.gz
    tar zxvf ncurses.tar.gz
    cd ncurses-${NCURSES_VERSION}

    # Patch
    for fname in ${OUR_DIR}/ncurses-*.diff;
    do
        patch -p1 < $fname
    done

    # Build
    CC='clang -flto -O3 -mmacosx-version-min=10.6' ./configure \
        --disable-shared \
        --enable-static
    make -j4
}

function build_readline() {
    cd ${ROOT_DIR}

    # Download
    curl -LO ftp://ftp.cwru.edu/pub/bash/readline-${READLINE_VERSION}.tar.gz
    tar xzvf readline-${READLINE_VERSION}.tar.gz
    cd readline-${READLINE_VERSION}

    # Build
    CC='clang -flto -O3 -mmacosx-version-min=10.6' ./configure \
        --disable-shared \
        --enable-static
    make -j4

    # Note that socat looks for readline in <readline/readline.h>, so we need
    # that directory to exist.
    ln -s ${ROOT_DIR}/readline-${READLINE_VERSION} ${ROOT_DIR}/readline
}

function build_openssl() {
    cd ${ROOT_DIR}

    # Download
    curl -LO https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz
    tar zxvf openssl-${OPENSSL_VERSION}.tar.gz
    cd openssl-${OPENSSL_VERSION}

    # Patch
    for fname in ${OUR_DIR}/openssl-*.diff;
    do
        patch -p1 < $fname
    done

    # Configure
    CC='clang -flto -O3 -mmacosx-version-min=10.6' ./Configure no-shared darwin64-x86_64-cc enable-ec_nistp_64_gcc_128

    # Build
    make
    echo "** Finished building OpenSSL"
}

function build_socat() {
    cd ${ROOT_DIR}

    # Download
    curl -LO http://www.dest-unreach.org/socat/download/socat-${SOCAT_VERSION}.tar.gz
    tar xzvf socat-${SOCAT_VERSION}.tar.gz
    cd socat-${SOCAT_VERSION}

    # Build
    CC='clang -flto -O3 -mmacosx-version-min=10.6' \
        CPPFLAGS="-I${ROOT_DIR} -I${ROOT_DIR}/openssl-1.0.2/include" \
        LDFLAGS="-L${ROOT_DIR}/readline-${READLINE_VERSION} -L${ROOT_DIR}/ncurses-${NCURSES_VERSION}/lib -L${ROOT_DIR}/openssl-${OPENSSL_VERSION}" \
        LIBS="${ROOT_DIR}/ncurses-${NCURSES_VERSION}/lib/libncurses.a" \
        ./configure
    make -j4
    strip socat
}

function doit() {
    build_ncurses
    build_readline
    build_openssl
    build_socat

    # Copy to output
    cp ${ROOT_DIR}/socat-${SOCAT_VERSION}/socat $OUR_DIR/../../binaries/darwin
    echo "** Finished **"
}

doit
