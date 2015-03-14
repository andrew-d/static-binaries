# static-binaries

This repo contains a bunch of statically-linked binaries of various tools,
along with the Dockerfiles / other build scripts that can be used to build
them.  I generally just create these as I need them.

## Current List of Tools

- [socat](http://www.dest-unreach.org/socat/)
- [ag / the_silver_searcher](https://github.com/ggreer/the_silver_searcher)
- [nmap](http://nmap.org/)
- [p0f v3](http://lcamtuf.coredump.cx/p0f3/)
- [binutils](https://www.gnu.org/software/binutils/)

## Building

Generally, if the directory contains a Dockerfile, you can run the build by
doing something like (where `FOO` is the directory name):

```
cd FOO
docker build -t static-binaries-FOO .
docker run -v `pwd`/../binaries:/output static-binaries-FOO
```

## Notes:

### nmap

- In order to do script scans, Nmap must know where the various Lua files live.
  You can do this by setting the `NMAPDIR` environment variable:  
    `NMAPDIR=/usr/share/nmap nmap -vvv -A www.target.com`

- The `nmap_centos5` binary isn't statically-linked; rather, it's built on
  CentOS5, so it "should" run on just about every modern version of Linux.
  Use this if something in the static binary doesn't work properly.
