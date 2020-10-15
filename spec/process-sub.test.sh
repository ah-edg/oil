
#### Process sub input
f=_tmp/process-sub.txt
{ echo 1; echo 2; echo 3; } > $f
cat <(head -n 2 $f) <(tail -n 2 $f)
## STDOUT:
1
2
2
3
## END

#### Process sub from external process to stdin
seq 3 > >(tac)
## STDOUT:
3
2
1
## END

#### Process sub from shell to stdin
{ echo 1; echo 2; echo 3; } > >(tac)
## STDOUT:
3
2
1
## END

#### Non-linear pipeline with >()
stdout_stderr() {
  echo o1
  echo o2

  sleep 0.1  # Does not change order

  { echo e1;
    echo warning: e2 
    echo e3;
  } >& 2
}
stdout_stderr 2> >(grep warning) | tac >$TMP/out.txt
wait $!  # this does nothing in bash 4.3, but probably does in bash 4.4.
echo OUT
cat $TMP/out.txt
# PROBLEM -- OUT comes first, and then 'warning: e2', and then 'o2 o1'.  It
# looks like it's because nobody waits for the proc sub.
# http://lists.gnu.org/archive/html/help-bash/2017-06/msg00018.html
## STDOUT:
OUT
warning: e2
o2
o1
## END

#### $(<file) idiom with process sub
echo FOO >foo

# works in bash and zsh
echo $(<foo)

# this works in zsh, but not in bash
tr A-Z a-z < <(<foo)

cat < <(<foo; echo hi)

## STDOUT:
FOO
hi
## END
## OK zsh STDOUT:
FOO
foo
FOO
hi
## END

#### status code is available
cat <(seq 2; exit 2) <(seq 3; exit 3)
echo status=${_process_sub_status[@]}
echo done

## STDOUT:
1
2
1
2
3
status=2 3
done
## END
## N-I bash/zsh STDOUT:
1
2
1
2
3
status=
done
## END
