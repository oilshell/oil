#!/usr/bin/env bash
#
# Junk drawer of repros for bugs
#
# Usage:
#   test/bugs.sh <function name>

set -o nounset
set -o pipefail
set -o errexit

# bugs:
# echo | tr
# echo | cat
# history | less

esrch-code-1() {
  local n=$1
  for i in $(seq $n); do
    echo 'echo hi | tr a-z A-Z'
    #echo 'echo hi | cat'
  done
}

esrch-code-2() {
  local n=$1
  for i in $(seq $n); do
    echo 'history | less'
  done
}

esrch-test() {
  # I think

  local osh=bin/osh

  local osh=_bin/cxx-opt/osh
  ninja $osh

  esrch-code-1 1000 | $osh -i
}

#
# Bug #1853 - trap and fork optimizations - also hit by Samuel
#

trap-1() {
  local sh=${1:-bin/osh}
  set +o errexit

  # This fails to run the trap
  $sh -x -c 'trap "echo int" INT; sleep 5'
}

# Run with bin/ysh -x to show fork opts
trap-2() {
  local sh=${1:-bin/osh}
  set +o errexit

  # This runs it
  $sh -x -c 'trap "echo int" INT; sleep 5; echo last'
}

trap-line() {
  echo outer line=$LINENO
  trap 'echo "trap line=$LINENO"' INT  # shows line 1
  sleep 5
  echo hi
}

bug-1853() {
  local sh=${1:-bin/osh}

  $sh -c 'trap "echo hi" EXIT; $(which true)'

  echo --
  # NEWLINE
  $sh -c 'trap "echo hi" EXIT; $(which true)
'

  echo --
  $sh -c 'trap "echo hi" EXIT; $(which true); echo last'
}

pipefail-bug() {
  local sh=${1:-bin/osh}
  set +o errexit

  # shopt --set no_last_fork causes this, combined with lastpipe
  # why does it work in bash/dash though?
  $sh -c '
set -o errexit
set -o pipefail
shopt -s lastpipe
ls | false | wc -l'
  echo status=$?
}

"$@"
