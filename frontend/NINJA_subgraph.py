"""
frontend/NINJA_subgraph.py
"""

from __future__ import print_function

from build import ninja_lib
from build.ninja_lib import log

_ = log


def NinjaGraph(ru):
  n = ru.n

  ru.comment('Generated by %s' % __name__)

  n.rule('consts-gen',
         command='_bin/shwrap/consts_gen $action $out_prefix',
         description='consts_gen $action $out_prefix')

  n.rule('flag-gen',
         command='_bin/shwrap/flag_gen $action $out_prefix',
         description='flag_gen $action $out_prefix')

  n.rule('option-gen',
         command='_bin/shwrap/option_gen $action $out_prefix',
         description='consts_gen $action $out_prefix')

  n.rule('signal-gen',
         command='_bin/shwrap/signal_gen $action $out_prefix',
         description='signal_gen $action $out_prefix')

  ru.py_binary('frontend/consts_gen.py')

  ru.py_binary('frontend/flag_gen.py')

  # TODO: hook this up
  #ru.py_binary('frontend/lexer_gen.py')

  ru.py_binary('frontend/option_gen.py')

  ru.py_binary('frontend/signal_gen.py')

  prefix = '_gen/frontend/id_kind.asdl'
  n.build([prefix + '.h', prefix + '.cc'], 'consts-gen', [],
          implicit=['_bin/shwrap/consts_gen'],
          variables=[
            ('out_prefix', prefix),
            ('action', 'cpp'),
          ])
  n.newline()

  # Similar to above
  prefix = '_gen/frontend/consts'
  n.build([prefix + '.h', prefix + '.cc'], 'consts-gen', [],
          implicit=['_bin/shwrap/consts_gen'],
          variables=[
            ('out_prefix', prefix),
            ('action', 'cpp-consts'),
          ])
  n.newline()

  prefix = '_gen/frontend/arg_types'
  n.build([prefix + '.h', prefix + '.cc'], 'flag-gen', [],
          implicit=['_bin/shwrap/flag_gen'],
          variables=[
            ('out_prefix', prefix),
            ('action', 'cpp'),
          ])
  n.newline()

  ru.cc_library(
      '//frontend/arg_types',
      generated_headers = ['_gen/frontend/arg_types.h'],
      srcs = ['_gen/frontend/arg_types.cc'],
      )

  ru.cc_binary(
      'frontend/arg_types_test.cc',
      deps = ['//frontend/arg_types'],
      matrix = ninja_lib.SMALL_TEST_MATRIX,
      )

  prefix = '_gen/frontend/option.asdl'
  # no .cc file
  n.build([prefix + '.h'], 'option-gen', [],
          implicit=['_bin/shwrap/option_gen'],
          variables=[
            ('out_prefix', prefix),
            ('action', 'cpp'),
          ])
  n.newline()

  prefix = '_gen/frontend/signal'
  n.build([prefix + '.h', prefix + '.cc'], 'signal-gen', [],
          implicit=['_bin/shwrap/signal_gen'],
          variables=[
            ('out_prefix', prefix),
            ('action', 'cpp'),
          ])
  n.newline()

  ru.asdl_library(
      'frontend/types.asdl',
      pretty_print_methods = False)

  ru.asdl_library(
      'frontend/syntax.asdl')

  if 0:
    ru.cc_binary(
        'frontend/syntax_asdl_test.cc',
        deps = ['//frontend/syntax.asdl'],
        matrix = ninja_lib.COMPILERS_VARIANTS)
