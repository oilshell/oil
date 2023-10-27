"""
core/NINJA_subgraph.py
"""

from __future__ import print_function

from build import ninja_lib
from build.ninja_lib import log

_ = log


def NinjaGraph(ru):
    n = ru.n

    ru.comment('Generated by %s' % __name__)

    ru.py_binary('core/optview_gen.py')

    n.rule(
        'optview-gen',
        # uses shell style
        command='_bin/shwrap/optview_gen > $out',
        description='optview_gen > $out')

    n.build(['_gen/core/optview.h'],
            'optview-gen', [],
            implicit=['_bin/shwrap/optview_gen'])
    n.newline()

    ru.cc_library('//core/optview',
                  srcs=[],
                  generated_headers=['_gen/core/optview.h'],
                  deps=['//frontend/option.asdl'])

    ru.cc_binary('core/optview_test.cc',
                 deps=['//core/optview'],
                 matrix=ninja_lib.SMALL_TEST_MATRIX)

    ru.asdl_library(
        'core/runtime.asdl',
        # 'use' dependency
        deps=['//frontend/syntax.asdl', '//core/value.asdl'])

    ru.asdl_library(
        'core/value.asdl',
        # 'use' dependency
        deps=['//frontend/syntax.asdl', '//core/runtime.asdl'])

    ru.cc_binary('core/runtime_asdl_test.cc',
                 deps=['//core/runtime.asdl'],
                 matrix=ninja_lib.SMALL_TEST_MATRIX)
