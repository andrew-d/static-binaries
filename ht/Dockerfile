FROM andrewd/musl-cross
MAINTAINER Andrew Dunham <andrew@du.nham.ca>

# Install build tools
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -yy && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yy \
        automake            \
        bison               \
        curl                \
        flex                \
        git                 \
        pkg-config          \
        texinfo             \
        vim

# Add our build script
ADD build.sh /build/build.sh

# This builds the program and copies it to /output
CMD /build/build.sh
