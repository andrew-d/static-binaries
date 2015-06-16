#!/bin/bash

set -e
set -o pipefail
set -x


ZLIB_VERSION=1.2.8
TERMCAP_VERSION=1.3.1
READLINE_VERSION=6.3
OPENSSL_VERSION=1.0.2c
PYTHON_VERSION=2.7.10


function build_zlib() {
    cd /build

    # Download
    curl -LO http://zlib.net/zlib-${ZLIB_VERSION}.tar.gz
    tar zxvf zlib-${ZLIB_VERSION}.tar.gz
    cd zlib-${ZLIB_VERSION}

    # Build
    CC='/opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-gcc -static -fPIC' \
        ./configure \
        --static
    make -j4
}

function build_termcap() {
    cd /build

    # Download
    curl -LO http://ftp.gnu.org/gnu/termcap/termcap-${TERMCAP_VERSION}.tar.gz
    tar zxvf termcap-${TERMCAP_VERSION}.tar.gz
    cd termcap-${TERMCAP_VERSION}

    # Build
    CC='/opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-gcc -static -fPIC' \
        ./configure \
        --disable-shared \
        --enable-static
    make -j4
}

function build_readline() {
    cd /build

    # Download
    curl -LO ftp://ftp.cwru.edu/pub/bash/readline-${READLINE_VERSION}.tar.gz
    tar xzvf readline-${READLINE_VERSION}.tar.gz
    cd readline-${READLINE_VERSION}

    # Build
    CC='/opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-gcc -static -fPIC' \
        ./configure \
        --disable-shared \
        --enable-static
    make -j4

    # Note that things look for readline in <readline/readline.h>, so we need
    # that directory to exist.
    ln -s /build/readline-${READLINE_VERSION} /build/readline-${READLINE_VERSION}/readline
}

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

function build_python() {
    cd /build

    # Download
    curl -LO https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tar.xz
    unxz Python-${PYTHON_VERSION}.tar.xz
    tar -xvf Python-${PYTHON_VERSION}.tar
    cd Python-${PYTHON_VERSION}

    # Set up modules
    cp Modules/Setup.dist Modules/Setup
    MODULES="_bisect _collections _csv _datetime _elementtree _functools _heapq _io _md5 _posixsubprocese _random _sha _sha256 _sha512 _socket _struct _weakref array binascii cmath cStringIO cPickle datetime fcntl future_builtins grp itertools math mmap operator parser readline resource select spwd strop syslog termios time unicodedata zlib"
    for mod in $MODULES;
    do
        sed -i -e "s/^#${mod}/${mod}/" Modules/Setup
    done

    echo '_json _json.c' >> Modules/Setup
    echo '_multiprocessing _multiprocessing/multiprocessing.c _multiprocessing/semaphore.c _multiprocessing/socket_connection.c' >> Modules/Setup

    # Enable static linking
    sed -i '1i\
*static*' Modules/Setup

    # Set dependency paths for zlib, readline, etc.
    sed -i \
        -e "s|^zlib zlibmodule.c|zlib zlibmodule.c -I/build/zlib-${ZLIB_VERSION} -L/build/zlib-${ZLIB_VERSION} -lz|" \
        -e "s|^readline readline.c|readline readline.c -I/build/readline-${READLINE_VERSION} -L/build/readline-${READLINE_VERSION} -L/build/termcap-${TERMCAP_VERSION} -lreadline -ltermcap|" \
        Modules/Setup

    # Enable OpenSSL support
    patch --ignore-whitespace -p1 < /build/cpython-enable-openssl.patch
    sed -i \
        -e "s|^SSL=/build/openssl-TKTK|SSL=/build/openssl-${OPENSSL_VERSION}|" \
        Modules/Setup

    # Configure
    CC='/opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-gcc -static -fPIC' \
        CXX='/opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-g++ -static -static-libstdc++ -fPIC' \
        LD=/opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-ld \
        ./configure \
            --disable-shared

    # Build
    make -j4
    /opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-strip python
}

function doit() {
    build_zlib
    build_termcap
    build_readline
    build_openssl
    build_python

    # Copy to output
    if [ -d /output ]
    then
        OUT_DIR=/output/`uname | tr 'A-Z' 'a-z'`/`uname -m`
        mkdir -p $OUT_DIR
        cp python $OUT_DIR/
        echo "** Finished **"
    else
        echo "** /output does not exist **"
    fi
}

doit
