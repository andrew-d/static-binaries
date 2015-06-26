#!/bin/bash

set -e
set -o pipefail
#set -x

PLATFORM=$1
ARCH=$2
IMAGE=$3
OUT_DIR=$4
Q=$5

# Colors
RED="\x1b[31m"
GREEN="\x1b[32m"
YELLOW="\x1b[33m"
BLUE="\x1b[34m"
RESET="\x1b[0m"
ERASE_LINE="\x1b[2K"

# Find our real path of this directory
REALPATH=
for bin in realpath grealpath; do
	##echo "Testing for ${bin}..."
	if [ -x "`which $bin`" ]; then
		REALPATH=`which $bin`
	fi
done

if [ -z "$REALPATH" ]; then
	printf "${RED}ERROR:${RESET} Could not find 'realpath' binary\n"
	exit 1
fi

ROOT=`$REALPATH .`

if [ -z "$PLATFORM" ]; then
	printf "${RED}ERROR:${RESET} No platform specified\n"
	exit 1
fi

if [ -z "$ARCH" ]; then
	printf "${RED}ERROR:${RESET} No architecture specified\n"
	exit 1
fi

if [ -z "$IMAGE" ]; then
	printf "${RED}ERROR:${RESET} No container specified\n"
	exit 1
fi

if [ ! -d "$OUT_DIR" ]; then
	printf "${RED}ERROR:${RESET} Output directory not given or not a directory\n"
	printf "    $$OUT_DIR = $OUT_DIR\n"
	exit 1
fi


CID=$(docker run \
	-d \
	--name=static-build-${PLATFORM}-${ARCH} \
	-v ${ROOT}/make:/make \
	-v ${OUT_DIR}:/output \
	$IMAGE \
	/bin/bash \
	-c "cd /make && make PLATFORM=${PLATFORM} ARCH=${ARCH} Q=$Q install"
)

DESC=$(printf "%s/%s" "$PLATFORM" "$ARCH")
HEADER=$(printf "  ${GREEN}%-10s${RESET} | ${BLUE}%-15s${RESET} | %s | " "DOCKER" "$DESC" "${CID:0:12}")

printf "${HEADER}${YELLOW}WAITING${RESET}"

EXIT_CODE=$(docker wait $CID)

if [ "$EXIT_CODE" == "0" ]; then
	docker rm $CID >/dev/null
	printf "\r${ERASE_LINE}${HEADER}${GREEN}SUCCESS${RESET}\n"
else
	printf "\r${ERASE_LINE}${HEADER}${RED}ERROR (code %d)${RESET}\n" "$EXIT_CODE"
fi
