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
    def __init__(self):
        self.__build_dirs = {}
        self.__flags = defaultdict(lambda: [])

    def build_dir_for(self, package):
        if package in self.__build_dirs:
            return self.__build_dirs[package]

        d = tempfile.mkdtemp()
        self.__build_dirs[package] = d
        return d

    @property
    def flags(self):
        return make_immutable(self.__flags)

    def add_flags(self, input):
        for k, v in input.items():
            self.__flags[k].extend(v)

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
        self.packages = {}
        for mod in mods:
            self.packages[mod.name] = normalize_module(mod)

    def build(self, package):
        build_order = self._get_build_order(package)

        # Get modules and run the builds.
        ctx = BuildContext()
        try:
            mods = tuple(self.packages[x] for x in build_order)
            self._build_all(mods, ctx)
        finally:
            ctx.cleanup()

    def _build_all(self, mods, ctx):
        # Collect and install all dev dependencies
        deps = []
        for mod in mods:
            deps.extend(mod.dev_dependencies)

        # Install them.
        subprocess.check_call(['apt-get', 'install'] + deps)

        # Fetch
        for mod in mods:
            mod.fetch(ctx)

        # Prepare
        for mod in mods:
            mod.prepare(ctx)

        # Build
        for mod in mods:
            # Build this module.
            mod.build(ctx)

            # Append the flags to the context's flags.
            ctx.add_flags(mod.flags)


    def _get_build_order(self, package):
        # Find the module that exposes this package.
        module = self.packages.get(package)
        if not module:
            raise Exception("package '%s' not found" % (package,))

        # Recursively collect dependency 'edges' - i.e. a tuple of (A, B) that
        # indicates that package A depends on package B.
        edges = self._get_dependency_edges(package)

        # Topologically sort all dependencies.
        return topological_sort(edges)

    def _get_dependency_edges(self, package):
        edges = []

        def recurse(current, path):
            if current in path:
                raise Exception("recursive dependency cycle detected: %r" % (
                    path + [current]))

            # Add edges for all dependencies, then recurse to them.
            for dep in self.packages[current]['dependencies']:
                edges.append((dep, current))
                recurse(dep, path + [current])

        try:
            recurse(package, [])
        except KeyError as e:
            raise Exception("dependency %r does not exist" % (e.args[0],))

        return edges
