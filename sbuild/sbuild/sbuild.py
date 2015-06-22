import os
import sys
import tempfile
import subprocess
from collections import defaultdict, deque

from .immutable import make_immutable
from .importer import import_modules_in_dir
from .normalize import InvalidModuleError, normalize_module
from .toposort import CycleException, topological_sort


class BuildContext(object):
    _DEFAULT_FLAGS = object()

    def __init__(self, mods, platform, arch):
        self.__modules = mods
        self.__platform = platform
        self.__arch = arch
        self.__build_dirs = {}

        # Mapping of package name --> flag name --> list of flags
        self.__flags = defaultdict(lambda: defaultdict(lambda: []))

        self._setup_flags()

    def build_dir_for(self, package):
        if package in self.__build_dirs:
            return self.__build_dirs[package]

        d = tempfile.mkdtemp()
        self.__build_dirs[package] = d
        return d

    @property
    def platform(self):
        return self.__platform

    @property
    def arch(self):
        return self.__arch

    def set_flags(self, name, flags):
        for fname, vals in flags.items():
            self.__flags[name][fname].extend(vals)

    def get_flags_for(self, name):
        """Get all flags for the module with the given name"""
        flags = defaultdict(lambda: [])
        for depname in self.__modules[name]['dependencies']:
            for fname, vals in self.__flags[depname].items():
                flags[fname].extend(vals)

        for fname, vals in self.__flags[self._DEFAULT_FLAGS].items():
            flags[fname].extend(vals)

        # Special case
        flags['CFLAGS'].append('-frandom-seed=build-%s' % (name,))
        flags['CXXFLAGS'].append('-frandom-seed=build-%s' % (name,))

        return flags

    def _setup_flags(self):
        # Build everything static by default.
        self.__flags[self._DEFAULT_FLAGS]['CFLAGS'].append('-static')

        # TODO: set more per-platform and per-arch default flags in here.

    def cleanup(self):
        for dname in self.__build_dirs:
            os.removedirs(dname)


class PackageBuilder(object):
    def __init__(self, output_dir, package_dir=None):
        self.output_dir = output_dir
        self.package_dir = package_dir
        if self.package_dir is None:
            self.package_dir = os.path.join(os.path.dirname(__file__), 'packages')

    def import_packages(self):
        # Import all modules
        mods = import_modules_in_dir(self.package_dir)

        # Build the dict of package name --> module.
        self.packages = defaultdict(list)
        for mod in mods:
            self.packages[mod.name].append(normalize_module(mod))

    def build(self, name, platform, arch='x86_64'):
        build_order = self._get_build_order(name, platform, arch)

        # Convert module names into descriptions.
        mods = tuple(self._find_package(x, platform, arch) for x in build_order)

        # Run the build.
        ctx = BuildContext(mods, platform, arch)
        try:
            self._build_all(mods, ctx)
        finally:
            ctx.cleanup()

    def _build_all(self, mods, ctx):
        # Collect and install all dev dependencies
        deps = []
        for mod in mods:
            deps.extend(mod['dev_dependencies'])

        # Install all dependencies - throws if there's a failure.
        subprocess.check_call(['apt-get', 'update'])
        subprocess.check_call(['apt-get', 'install'] + deps)

        # Fetch sources, prepare, and then build.
        for mod in mods:
            mod['fetch'](ctx)

        for mod in mods:
            if 'prepare' in mod:
                mod['prepare'](ctx)

        for mod in mods:
            mod['build'](ctx)
            ctx.add_flags(mod['name'], mod['flags'])

        # Finish will handle any cleanup or copying the output.
        for mod in mods:
            if 'finish' in mod:
                mod['finish'](ctx)

    def _find_package(self, name, platform, arch):
        candidates = self.packages.get(name)
        if not candidates:
            raise Exception("package '%s' not found" % (name,))

        for c in candidates:
            if c['platform'] == platform and c['architecture'] == arch:
                return c

        raise Exception("no candidate found for package '%s' with " +
                        "platform/arch: %s/%s" % (name, platform, arch))

    def _get_build_order(self, name, platform, arch):
        # Find the module that exposes this package.
        module = self._find_package(name, platform, arch)
        if not module:
            raise Exception("package '%s' not found" % (name,))

        # Recursively collect dependency 'edges' - i.e. a tuple of (A, B) that
        # indicates that package A depends on package B.
        edges = self._get_dependency_edges(name, platform, arch)

        # Topologically sort all dependencies.
        return topological_sort(edges)

    def _get_dependency_edges(self, name, platform, arch):
        edges = []

        def recurse(current, path):
            if current in path:
                raise Exception("recursive dependency cycle detected: %r" % (
                    path + [current]))

            # Add edges for all dependencies, then recurse to them.
            package = self._find_package(current, platform, arch)
            for dep in package['dependencies']:
                edges.append((dep, current))
                recurse(dep, path + [current])

        try:
            recurse(name, [])
        except KeyError as e:
            raise Exception("dependency %r does not exist" % (e.args[0],))

        return edges
