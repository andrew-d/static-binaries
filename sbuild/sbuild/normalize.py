from .immutable import make_immutable

# Required attributes (all strings)
REQUIRED_ATTRS = ['name', 'platform', 'architecture', 'version']

# Format (name, constructor for default)
OPTIONAL_ATTRS = [
    ('dependencies', lambda: ()),
    ('dev_dependencies', lambda: ()),
    ('flags', lambda: frozendict()),
]

# Format (name, required)
MODULE_FUNCTIONS = [
    ('fetch', True),
    ('prepare', False),
    ('build', True),
    ('finish', False),
]

VALID_PLATFORMS = ['linux', 'darwin', 'windows']
VALID_PLATFORMS = ['x86', 'x86_64', 'arm']


class InvalidModuleError(Exception):
    pass


def normalize_module(self, name, module):
    missing = object()

    ret = {}

    for attr in REQUIRED_ATTRS:
        val = getattr(module, attr, missing)
        if val is missing:
            raise InvalidModuleError("package '%s' missing attribute '%s'" % (
                name, attr))
        if not isinstance(val, str):
            raise InvalidModuleError("package '%s' has attribute '%s' that "+
                                     "is not a string" % (name, attr))

        ret[attr] = val

    for (attr, ctor) in OPTIONAL_ATTRS:
        val = getattr(module, attr, missing)
        if val is missing:
            val = ctor()

        ret[attr] = make_immutable(val)

    for (fname, required) in MODULE_FUNCTIONS:
        val = getattr(module, fname, missing)
        if val is missing and required:
            raise InvalidModuleError("package '%s' is missing required " +
                                     "function '%s'" % (name, fname))

        if not hasattr(val, '__call__'):
            raise InvalidModuleError("package '%s' has function '%s' that is " +
                                     "not callable" % (name, fname))

        ret[fname] = val

    if ret['platform'] not in VALID_PLATFORMS:
        raise InvalidModuleError("package '%s' has invalid platform '%s'" % (
            name, ret['platform']))

    if ret['architecture'] not in VALID_ARCHITECTURES:
        raise InvalidModuleError("package '%s' has invalid architecture '%s'" % (
            name, ret['architecture']))

    return frozendict(item)
