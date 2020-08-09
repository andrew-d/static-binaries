#!/bin/bash

# this script runs inside an Alpine docker container created by ./set_up.sh

if ! command -v wget >/dev/null 2>&1; then
    apk add wget
fi

wget https://www.tcpdump.org/release/tcpdump-4.9.3.tar.gz
tar -xvpf tcpdump-4.9.3.tar.gz
cd tcpdump-4.9.3 || (
    echo "tcpdump source not found"
    exit 1
)

apk add libpcap-dev || exit 1

LDFLAGS=-static ./configure || (
    echo -e "\n\n Failed to configure,check the error output"
    exit 1
)

make -j4 || (
    echo -e "\n\n Failed to build tcpdump, check the error output"
    exit 1
)

echo -e "\n\n TCPDUMP has been built:"
ls -lh "$PWD"/tcpdump
