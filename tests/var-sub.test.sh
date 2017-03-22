#!/bin/bash
#
# Corner cases in var sub.  Maybe rename this file.

### Braced block inside ${}
# NOTE: This doesn't work in bash.  The nested {} aren't parsed.  It works in
# dash though!
# bash - line 1: syntax error near unexpected token `)'
# bash - line 1: `echo ${foo:-$({ which ls; })}'
# tag: bash-bug
echo ${foo:-$({ which ls; })}
# stdout: /bin/ls
# BUG bash stdout-json: ""
# BUG bash status: 2

### Assigning $@ to var
# dash doesn't like this -- says '2' bad variable name.
# NOTE: bash and mksh support array variables!  This is probably the
# difference.  Need to test array semantics!
func() {
  local v=$@
  argv.py $v
}
func 1 2 3
# stdout: ['1', '2', '3']
# BUG dash status: 2
# BUG dash stdout-json: ""

### Assigning "$@" to var
# dash doesn't like this -- says '2 3' bad variable name.
func() {
  local v="$@"
  argv.py $v
}
func 1 '2 3'
# stdout: ['1', '2', '3']
# BUG dash status: 2
# BUG dash stdout-json: ""

### Assigning "$@" to var, then showing it quoted
# dash doesn't like this -- says '2 3' bad variable name.
func() {
  local v="$@"
  argv.py "$v"
}
func 1 '2 3'
# stdout: ['1 2 3']
# BUG dash status: 2
# BUG dash stdout-json: ""

### Filename redirect with "$@" 
# bash - ambiguous redirect -- yeah I want this error
#   - But I want it at PARSE time?  So is there a special DollarAtPart?
#     MultipleArgsPart?
# mksh - tries to create '_tmp/var-sub1 _tmp/var-sub2'
# dash - tries to create '_tmp/var-sub1 _tmp/var-sub2'
func() {
  echo hi > "$@"
}
func _tmp/var-sub1 _tmp/var-sub2
# status: 1
# OK dash status: 2

### Filename redirect with split word
# bash - runtime error, ambiguous redirect
# mksh and dash - they will NOT apply word splitting after redirect, and write
# to '_tmp/1 2'
# Stricter behavior seems fine.
foo='_tmp/1 2'
rm '_tmp/1 2'
echo hi > $foo
test -f '_tmp/1 2' && cat '_tmp/1 2'
# status: 1
# OK dash/mksh status: 0
# OK dash/mksh stdout: hi

### Descriptor redirect to bad "$@"
# All of them give errors:
# dash - bad fd number, parse error?
# bash - ambiguous redirect
# mksh - illegal file scriptor name
set -- '2 3' 'c d'
echo hi 1>& "$@"
# status: 2
# OK bash/mksh status: 1

### Here doc with bad "$@" delimiter
# bash - syntax error
# dash - syntax error: end of file unexpected
# mksh - runtime error: here document unclosed
#
# What I want is syntax error: bad delimiter!
#
# This means that "$@" should be part of the parse tree then?  Anything that
# involves more than one token.
func() {
  cat << "$@"
hi
1 2
}
func 1 2
# status: 2
# stdout-json: ""
# OK mksh status: 1

