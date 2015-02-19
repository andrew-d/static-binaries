#!/bin/bash

set -e
set -o pipefail
set -x


MUSL_VERSION=1.1.6
SOCAT_VERSION=1.7.3.0
NCURSES_VERSION=5.9
READLINE_VERSION=6.3
OPENSSL_VERSION=1.0.2


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

function build_ncurses() {
    cd /build

    # Download
    curl -LO http://invisible-island.net/datafiles/release/ncurses.tar.gz
    tar zxvf ncurses.tar.gz
    cd ncurses-${NCURSES_VERSION}

    # Build
    CC='/usr/local/musl/bin/musl-gcc -static' CFLAGS='-fPIC' ./configure \
        --disable-shared \
        --enable-static
}

function build_readline() {
    cd /build

    # Download
    curl -LO ftp://ftp.cwru.edu/pub/bash/readline-${READLINE_VERSION}.tar.gz
    tar xzvf readline-${READLINE_VERSION}.tar.gz
    cd readline-${READLINE_VERSION}

    # Build
    CC='/usr/local/musl/bin/musl-gcc -static' CFLAGS='-fPIC' ./configure \
        --disable-shared \
        --enable-static
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

    # Patch to make OpenSSL support MUSL
    patch -p1 <<EOF
--- a/crypto/ui/ui_openssl.c
+++ b/crypto/ui/ui_openssl.c
@@ -190,9 +190,9 @@
 # undef  SGTTY
 #endif
 
-#if defined(linux) && !defined(TERMIO)
-# undef  TERMIOS
-# define TERMIO
+#if defined(linux)
+# define TERMIOS
+# undef  TERMIO
 # undef  SGTTY
 #endif
 
EOF

    # Configure
    CC='/usr/local/musl/bin/musl-gcc -static' ./Configure no-shared linux-x86_64

    # Build
    make -j4
}

function build_socat() {
    cd /build

    # Download
    curl -LO http://www.dest-unreach.org/socat/download/socat-${SOCAT_VERSION}.tar.gz
    tar xzvf socat-${SOCAT_VERSION}.tar.gz
    cd socat-${SOCAT_VERSION}

    # Build
    # NOTE: `NETDB_INTERNAL` is non-POSIX, and thus not defined by MUSL.
    # We define it this way manually.
    CC='/usr/local/musl/bin/musl-gcc -static' \
        CFLAGS='-fPIC' \
        CPPFLAGS='-I/build -I/build/openssl-1.0.2/include -DNETDB_INTERNAL=-1' \
        LDFLAGS="-L/build/readline-${READLINE_VERSION} -L/build/ncurses-${NCURSES_VERSION}/lib -L/build/openssl-${OPENSSL_VERSION}" \
        ./configure
    make -j4
    strip socat
}

function doit() {
    build_musl
    build_ncurses
    build_readline
    build_openssl
    build_socat

    # Copy to output
    if [ -d /output ]
    then
        OUT_DIR=/output/`uname | tr 'A-Z' 'a-z'`/`uname -m`
        mkdir -p $OUT_DIR
        cp /build/socat-${SOCAT_VERSION}/socat $OUT_DIR/
        echo "** Finished **"
    else
        echo "** /output does not exist **"
    fi
}

doit
