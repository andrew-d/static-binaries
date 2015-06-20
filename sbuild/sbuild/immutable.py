import collections

from .frozendict import frozendict

def make_immutable(val):
    if isinstance(val, collections.Set):
        return frozenset(make_immutable(x) for x in val)

    elif isinstance(val, collections.Mapping):
        return frozendict(
            (make_immutable(k), make_immutable(v)) for k, v in val.items()
        )

    elif isinstance(val, collection.Sequence):
        return tuple([make_immutable(x) for x in val])

    else:
        return val
