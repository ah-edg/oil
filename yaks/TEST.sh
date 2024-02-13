#!/usr/bin/env bash
#
# Usage:
#   yaks/TEST.sh <function name>

set -o nounset
set -o pipefail
set -o errexit

source build/dev-shell.sh  # python3 in PATH
source devtools/run-task.sh
source test/common.sh  # run-test-funcs

build() {
  build/py.sh gen-asdl-py 'yaks/yaks.asdl'
}

check() {
  build

  # pyext/fastfunc is a dependency of ASDL
  # Source is Python 2

  # These flags are in devtools/types.sh
  #local mypy_flags='--strict --no-strict-optional'

  # 514 errors!  Not sure why we need the extra flag.
  #local mypy_flags='--strict'
  local mypy_flags='--strict --follow-imports=silent'

  MYPYPATH='.:pyext' python3 -m \
    mypy $mypy_flags --py2 yaks/yaks_main.py
}

yaks() {
  PYTHONPATH='.:vendor' yaks/yaks_main.py "$@"
}

test-hello() {
  yaks cpp yaks/examples/hello.yaks

  # TODO: fibonacci program, etc. building up to yaks in yaks itself.

  # type check only
  # yaks/yaks.py check testdata/hello.yaks
}

test-hello-cpp() {
  # Translate and compile the yaks translator
  #local bin=_bin/cxx-asan/yaks/yaks_main.mycpp
  #ninja $bin

  # Generate C++ from an example
  #$bin cpp yaks/examples/hello.yaks

  # Translate and compile the yaks translator
  # Then use it to generate C++ from an example
  # Then wrap and compile that
  local hello=_bin/cxx-asan/yaks/examples/hello.yaks
  ninja $hello

  set -o xtrace
  set +o errexit
  $hello
  local status=$?
  set -o errexit

  echo status=$status
}

soil-run() {
  ### Used by soil/worker.sh.  Prints to stdout.

  # Hm I guess we need the Python 2 wedge here.  Right now deps/Dockerfile.pea
  # has a Python 3 wedge and MyPy, which we still need.
  #echo 'Disabled until container image has python2-dev to build pyext/fastfunc'
  #return

  run-test-funcs

  check
}

run-task "$@"
