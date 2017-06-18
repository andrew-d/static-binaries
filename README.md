# static-binaries

This repo contains a bunch of statically-linked binaries of various tools,
along with the Dockerfiles / other build scripts that can be used to build
them.  I generally just create these as I need them - not all tools are
available for every platform or architecture.  Please [file an issue][1]
if you want a new tool or a tool on a new platform.

## Current List of Tools

- [ag / the_silver_searcher](https://github.com/ggreer/the_silver_searcher)
- [binutils](https://www.gnu.org/software/binutils/)
- [file](http://www.darwinsys.com/file/)
- [ht](https://github.com/sebastianbiallas/ht)
- [nano](https://www.nano-editor.org)
- [nmap](http://nmap.org)
- [p0f v3](http://lcamtuf.coredump.cx/p0f3/)
- [pv (Pipe Viewer)](https://www.ivarch.com/programs/pv.shtml)
- [python](https://www.python.org)
- [socat](http://www.dest-unreach.org/socat/)
- [strace](http://linux.die.net/man/1/strace)
- [tcpdump](http://www.tcpdump.org)
- [yasm](http://yasm.tortall.net)

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

- On Windows, the nmap binary will probably not work without WinPcap.  It also
  appears to have a random crashing problem with regular TCP scans - I'm not
  quite sure what's up with that yet.

### nping

- On Windows, nping has the same issues as nmap (see above).

### python

- Getting a static build of Python that works is **HARD**.  Not everything in this
  particular tool functions properly, and you have to run it with some strange options,
  but it's usable.  In short, you need to run it like so:  
    `PYTHONPATH=/path/to/python2.7.zip python -sS`

- Note: sqlite isn't currently supported.  Adding this is an ongoing TODO of mine.

### ht

- On Linux, the appropriate terminal information must be present.  On some versions of
  Linux (e.g. Debian Jessie), the information may be in a different place - you can use
  the `TERMINFO` environment variable to specify the correct location:
  `TERMINFO=/lib/terminfo ./ht`

## file

- You need to pass the correct magic database to file - one is provided named
  `magic.mgc`.  Run `file` as such: `file -m /path/to/magic.mgc myfile.foo`.

[1]: https://github.com/andrew-d/static-binaries/issues/new
