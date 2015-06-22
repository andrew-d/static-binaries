# Random Thoughts

- We could/should write a build manager that automates a lot of the common tasks.
  - The manager would run WITHIN the Docker container - i.e. it doesn't know
    anything about Docker itself.
  - Have the build manager enumerate and require all SBUILD files
  - Each SBUILD file allows building a single library (statically) for a
    single platform and architecture (i.e. different SBUILD for linux and
    mac, and within linux, a different one for Linux/x64 and Linux/ARM)
  - SBUILDs are declarative - should expose:
     * package name
     * platform
     * architecture
     * package version
     * dependencies (if any, other SBUILDs)
     * build dependencies (if any, would be apt-get install'd)
     * fetch function which retrieves all sources
     * prepare function which prepares for building (incl. running any
       configure scripts, if necessary)
     * build function that runs the build
     * various flags (i.e. -I${thisdir} or -L{thisdir} -lthelibrary)
     * finish function that allows copying build artefacts to output
  - When we call 'sbuild thing', we topologically sort all libraries that
    need to be built, build them all in order, and then run all the finish
    functions at the end

- NOTE: The above is ... pretty much what Makefiles are designed for, despite
  the fact that writing them isn't particularly pleasant.  While writing a new
  thing would be fun, NIH syndrome is also a thing, and Make solves a lot of
  these problems already.
  Alternatively (to support, e.g. package installation): http://pydoit.org
