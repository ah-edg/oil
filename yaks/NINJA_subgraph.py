"""
yaks/NINJA_subgraph.py
"""
from __future__ import print_function

from build import ninja_lib
from build.ninja_lib import log

_ = log

# TODO: should have dependencies with sh_binary
RULES_PY = 'build/ninja-rules-py.sh'


def NinjaGraph(ru):
    n = ru.n

    ru.comment('Generated by %s' % __name__)

    # yaks compiler
    main_name = 'yaks_main'
    with open('_build/NINJA/yaks.%s/translate.txt' % main_name) as f:
        deps = [line.strip() for line in f]

    prefix = '_gen/yaks/%s.mycpp' % main_name
    outputs = [prefix + '.cc', prefix + '.h']
    n.build(outputs,
            'gen-oils-for-unix',
            deps,
            implicit=['_bin/shwrap/mycpp_main', RULES_PY],
            variables=[('out_prefix', prefix), ('main_name', main_name)])

    ru.cc_binary(
        '_gen/yaks/%s.mycpp.cc' % main_name,
        # Note: yaks/yaks.py is bad for Python imports, so it's called
        # yaks_main.py
        bin_path='yaks',
        preprocessed=True,
        matrix=ninja_lib.COMPILERS_VARIANTS + ninja_lib.GC_PERF_VARIANTS,
        deps=[
            '//core/optview',  # TODO: remove this dep
            '//core/runtime.asdl',
            '//core/value.asdl',
            '//cpp/data_lang',
            '//cpp/frontend_match',
            '//data_lang/nil8.asdl',
            '//frontend/consts',
            '//mycpp/runtime',
        ])


# vim: sw=4