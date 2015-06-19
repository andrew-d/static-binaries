#!/bin/bash

set -e
set -o pipefail
set -x


SOCAT_VERSION=1.7.3.0
NCURSES_VERSION=5.9
READLINE_VERSION=6.3
OPENSSL_VERSION=1.0.2c


function build_ncurses() {
    cd /build

    # Download
    curl -LO http://invisible-island.net/datafiles/release/ncurses.tar.gz
    tar zxvf ncurses.tar.gz
    cd ncurses-${NCURSES_VERSION}

    # Patch
    for fname in /build/ncurses-*.diff;
    do
        patch -p1 < $fname
    done

    # Build
    AR=x86_64-apple-darwin12-ar \
    CC='x86_64-apple-darwin12-clang -flto -O3 -mmacosx-version-min=10.6' \
    CXX='x86_64-apple-darwin12-clang++ -flto -O3 -mmacosx-version-min=10.6' \
    CFLAGS='-frandom-seed=build-ncurses-darwin' \
    RANLIB=x86_64-apple-darwin12-ranlib \
        ./configure \
        --disable-shared \
        --enable-static \
        --build=i686 \
        --host=x86_64-apple-darwin
    OSXCROSS_NO_INCLUDE_PATH_WARNINGS=1 make -j4 libs
}

function build_readline() {
    cd /build

    # Download
    curl -LO ftp://ftp.cwru.edu/pub/bash/readline-${READLINE_VERSION}.tar.gz
    tar xzvf readline-${READLINE_VERSION}.tar.gz
    cd readline-${READLINE_VERSION}

    # Prevent building examples (which can't be done when cross-compiling)
    sed -i -e 's|examples/Makefile||g' configure.ac
    autoconf

    # Build
    AR=x86_64-apple-darwin12-ar \
    CC='x86_64-apple-darwin12-clang -flto -O3 -mmacosx-version-min=10.6' \
    CXX='x86_64-apple-darwin12-clang++ -flto -O3 -mmacosx-version-min=10.6' \
    CFLAGS='-frandom-seed=build-readline-darwin' \
    LD=x86_64-apple-darwin12-clang \
    RANLIB=x86_64-apple-darwin12-ranlib \
        ./configure \
        --disable-shared \
        --enable-static \
        --build=i686 \
        --host=x86_64-apple-darwin
    make -j4

    # Note that socat looks for readline in <readline/readline.h>, so we need
    # that directory to exist.
    ln -s /build/readline-${READLINE_VERSION} /build/readline
}

function build_openssl() {
    cd /build

    # Download
    curl -LO https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz
    tar zxvf openssl-${OPENSSL_VERSION}.tar.gz
    cd openssl-${OPENSSL_VERSION}

    # Configure
    AR=x86_64-apple-darwin12-ar \
    RANLIB=x86_64-apple-darwin12-ranlib \
    CFLAGS='-frandom-seed=build-openssl-darwin' \
    CC='x86_64-apple-darwin12-clang -flto -O3 -mmacosx-version-min=10.6' \
        ./Configure \
        no-shared \
        darwin64-x86_64-cc \
        enable-ec_nistp_64_gcc_128

    # Build
    make build_libs
    echo "** Finished building OpenSSL"
}

function build_socat() {
    cd /build

    # Download
    curl -LO http://www.dest-unreach.org/socat/download/socat-${SOCAT_VERSION}.tar.gz
    tar xzvf socat-${SOCAT_VERSION}.tar.gz
    cd socat-${SOCAT_VERSION}

    # Build
    AR=x86_64-apple-darwin12-ar \
    CC='x86_64-apple-darwin12-clang -flto -O3 -mmacosx-version-min=10.6' \
    CXX='x86_64-apple-darwin12-clang++ -flto -O3 -mmacosx-version-min=10.6' \
    LD=x86_64-apple-darwin12-clang \
    RANLIB=x86_64-apple-darwin12-ranlib \
    CFLAGS='-frandom-seed=build-socat-darwin' \
    CPPFLAGS="-I/build -I/build/openssl-${OPENSSL_VERSION}/include" \
    LDFLAGS="-L/build/readline-${READLINE_VERSION} -L/build/ncurses-${NCURSES_VERSION}/lib -L/build/openssl-${OPENSSL_VERSION}" \
    LIBS="/build/ncurses-${NCURSES_VERSION}/lib/libncurses.a" \
        ./configure \
        --build=i686 \
        --host=x86_64-apple-darwin

    make -j4
    x86_64-apple-darwin12-strip socat
}

function doit() {
    build_ncurses
    build_readline
    build_openssl
    build_socat

    # Copy to output
    # Copy to output
    if [ -d /output ]
    then
        OUT_DIR=/output/darwin
        mkdir -p $OUT_DIR
        cp /build/socat-${SOCAT_VERSION}/socat $OUT_DIR/
        echo "** Finished **"
    else
        echo "** /output does not exist **"
    fi
}

doit
