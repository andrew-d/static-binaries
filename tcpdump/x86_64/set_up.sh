#!/bin/bash

# set up Alpine docker container and copy our build script into it

if ! command -v docker >/dev/null 2>&1; then
    echo "Please install Docker first"
    exit 1
fi

docker pull alpine || (
    echo "docker pull failed, make sure docker is usable"
    exit 1
)

docker run --name alpine_tcpdump -it alpine /bin/sh -i
docker cp ./build.sh alpine_tcpdump:/root/build_tcpdump.sh
docker exec -it alpine_tcpdump /bin/sh /root/build_tcpdump.sh
