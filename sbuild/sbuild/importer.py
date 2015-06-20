import os
import imp
import glob


def import_modules_in_dir(directory):
    """Imports and returns all importable modules in the given directory."""
    assert os.path.isdir(directory)

    modules = {}

    for path in glob.glob(join(directory,'[!_]*.py')):
        if not os.path.isfile(os.path.join(directory, path)):
            continue

        name, ext = os.path.splitext(basename(path))
        modules[name] = imp.load_source(name, path)  # TODO: importlib.machinery.SourceFileLoader on Py3

    return modules
