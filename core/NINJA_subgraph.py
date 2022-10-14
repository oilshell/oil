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

  n.rule('optview-gen',
         # uses shell style
         command='_bin/shwrap/optview_gen > $out',
         description='optview_gen > $out')

  ru.py_binary('core/optview_gen.py')

  n.build(['_gen/core/optview.h'], 'optview-gen', [],
          implicit=['_bin/shwrap/optview_gen'])
  n.newline()

  # TODO: dependency for #include options.asdl.h
  ru.cc_library(
      '//core/optview',
      srcs = [],
      generated_headers = ['_gen/core/optview.h'])

  ru.cc_binary(
      'core/optview_test.cc',
      deps = ['//core/optview'],
      matrix = ninja_lib.SMALL_TEST_MATRIX)

  ru.asdl_library(
      'core/runtime.asdl',
      deps = ['//frontend/syntax.asdl'])
