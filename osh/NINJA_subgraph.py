"""
osh/NINJA_subgraph.py
"""

from __future__ import print_function

from build.ninja_lib import log

_ = log


def NinjaGraph(ru):
  n = ru.n

  ru.comment('Generated by %s' % __name__)

  n.build(['_gen/osh/arith_parse.cc'], 'arith-parse-gen', [],
          implicit=['_bin/shwrap/arith_parse_gen'])
  n.newline()

