import os
import sys
import unittest

sys.path.insert(0, os.path.abspath(
    os.path.join(os.path.dirname(__file__), '..')
))
from sbuild import sbuild


class TestDependencyResolution(unittest.TestCase):
    def setUp(self):
        self.b = sbuild.PackageBuilder('/tmp')

    def test_simple_dependencies(self):
        self.b.packages = {
            'one': {
                'name': 'one',
                'dependencies': ['two'],
            },
            'two': {
                'name': 'two',
                'dependencies': [],
            },
        }

        assert self.b._get_build_order('one') == ['two', 'one']

    def test_multiple_dependencies(self):
        self.b.packages = {
            'one': {
                'name': 'one',
                'dependencies': ['two', 'three'],
            },
            'two': {'name': 'two', 'dependencies': []},
            'three': {'name': 'three', 'dependencies': []},
        }

        assert self.b._get_build_order('one') == ['three', 'two', 'one']

    def test_recursive_dependencies(self):
        self.b.packages = {
            'one': {
                'name': 'one',
                'dependencies': ['two'],
            },
            'two': {
                'name': 'two',
                'dependencies': ['three'],
            },
            'three': {
                'name': 'three',
                'dependencies': [],
            },
        }

        assert self.b._get_build_order('one') == ['three', 'two', 'one']
