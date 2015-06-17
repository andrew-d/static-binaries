FROM debian:jessie
MAINTAINER Andrew Dunham <andrew@du.nham.ca>

# Install build tools
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -yy && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yy \
        automake            \
        build-essential     \
        curl                \
        file                \
        git                 \
        pkg-config          \
        wget

# Install musl-cross
RUN mkdir /build &&                                                 \
    cd /build &&                                                    \
    git clone https://github.com/GregorR/musl-cross.git &&          \
    cd musl-cross &&                                                \
    echo 'ARCH=arm'                                 >> config.sh && \
    echo 'TRIPLE=arm-linux-musleabihf'              >> config.sh && \
    echo 'GCC_BOOTSTRAP_CONFFLAGS="--with-arch=armv6 --with-float=hard --with-fpu=vfp"' >> config.sh && \
    echo 'GCC_CONFFLAGS="--with-arch=armv6 --with-float=hard --with-fpu=vfp"' >> config.sh && \
    echo 'GCC_BUILTIN_PREREQS=yes'                  >> config.sh && \
    sed -i -e 's/^MUSL_VERSION=.*$/MUSL_VERSION=1.1.10/' defs.sh && \
    ./build.sh

CMD /bin/bash
