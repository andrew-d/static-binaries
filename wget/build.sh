#!/bin/bash

set -e
set -o pipefail
set -x

WGET_VERSION=1.19.2
OPENSSL_VERSION=1.1.0g

function build_openssl() {
    cd /build

    # Download
    curl -LO https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz
    tar zxvf openssl-${OPENSSL_VERSION}.tar.gz
    cd openssl-${OPENSSL_VERSION}

    # Configure
    CC='/usr/bin/gcc -static' ./Configure no-shared no-async linux-x86_64

    # Build
    make -j4
    echo "** Finished building OpenSSL"
}

function build_wget() {
  cd /build

  # Download
  curl -LO https://ftp.gnu.org/gnu/wget/wget-${WGET_VERSION}.tar.gz
  tar -zxvf wget-${WGET_VERSION}.tar.gz
  cd wget-${WGET_VERSION}

  # Build
  CC='/usr/bin/gcc -static' \
    CFLAGS='-fPIC' \
    CPPFLAGS="-I/build" \
    LDFLAGS="-L/build/openssl-${OPENSSL_VERSION}" \
    OPENSSL_CFLAGS="-I/build/openssl-${OPENSSL_VERSION}/include" \
    OPENSSL_LIBS="-lssl -lcrypto" \
    ./configure \
    --with-ssl=openssl
  make -j4
  strip src/wget
}

function doit() {
    build_openssl
    build_wget

    # Copy to output
    if [ -d /output ]
    then
        OUT_DIR=/output/`uname | tr 'A-Z' 'a-z'`/`uname -m`
        mkdir -p $OUT_DIR
        cp /build/wget-${WGET_VERSION}/src/wget $OUT_DIR/
        echo "** Finished **"
    else
        echo "** /output does not exist **"
    fi
}

doit

