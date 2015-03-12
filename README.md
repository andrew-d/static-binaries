# static-binaries

This repo contains a bunch of statically-linked binaries of various tools,
along with the Dockerfiles / other build scripts that can be used to build
them.  I generally just create these as I need them.

## Current List of Tools

- [socat](http://www.dest-unreach.org/socat/)
- [ag / the_silver_searcher](https://github.com/ggreer/the_silver_searcher)

## Notes:

- The `nmap_centos5` binary isn't statically-linked; rather, it's built on
  CentOS5, so it "should" run on just about every modern version of Linux.
  Getting a proper statically-linked version of nmap is surprisingly tricky.
