#!/usr/bin/env bash
#
# Run the osh parser on shell scripts found in the wild.
#
# Usage:
#   ./wild.sh <function name>
#
# TODO:
# - There are a lot of hard-coded source paths here.  These files could
# published in a tarball or torrent.
# - Add gentoo
# - Add a quick smoke test that excludes distros and big ones, etc.
#   - Just do a regex

set -o nounset
set -o pipefail
set -o errexit

readonly RESULT_DIR=_tmp/wild

#
# Helpers
#

_manifest() {
  local proj=$1
  local base_dir=$2
  shift 2

  for path in "$@"; do
    echo $proj $base_dir/$path $path
  done
}

# generic helper
_sh-manifest() {
  local base_dir=$1
  local category=${2:-}

  local proj
  if test -n "$category"; then
    proj="$category/$(basename $base_dir)"
  else
    proj="$(basename $base_dir)"
  fi

  _manifest $proj $base_dir \
    $(find $base_dir -name '*.sh' -a -printf '%P\n')
}

_configure-manifest() {
  local base_dir=$1
  shift

  local name=$(basename $base_dir)
  _manifest ${name}__configure $base_dir \
    $(find $src -name 'configure' -a -printf '%P\n')
}

#
# Special Case Corpora Using Explicit Globs
#

# TODO: Where do we write the base dir?
oil-sketch-manifest() {
  local base_dir=~/git/oil-sketch
  pushd $base_dir >/dev/null
  for name in *.sh {awk,demo,make,misc,regex,tools}/*.sh; do
    echo oil-sketch $base_dir/$name $name
  done
  popd >/dev/null
}

oil-manifest() {
  local base_dir=$PWD
  for name in \
    configure install *.sh {benchmarks,build,test,scripts,opy}/*.sh; do
    echo oil $base_dir/$name $name
  done
}

readonly ABORIGINAL_DIR=~/src/aboriginal-1.4.5

#
# All
#

all-manifests() {
  # Don't expose this repo for now
  #oil-sketch-manifest

  #
  # My Code
  #

  oil-manifest

  local src

  #
  # Books
  #
  src=~/git/wild/books/wicked_cool_shell_scripts_2e
  _manifest "books/$(basename $src)" $src \
    $(find $src \
      \( -name .git -a -prune \) -o \
      \( -type f -a -executable -a -printf '%P\n' \) )

  #
  # Shell/Bash Frameworks/Collections
  #

  src=~/git/other/bash-completion
  _manifest "shell/$(basename $src)" $src \
    $(find $src/completions -type f -a -printf 'completions/%P\n')

  # Bats bash test framework.  It appears to be fairly popular.
  src=~/git/other/bats
  _manifest "shell/$(basename $src)" $src \
    $(find $src \
      \( -wholename '*/libexec/*' -a -type f -a \
         -executable -a -printf '%P\n' \) )

  # Bash debugger?
  src=~/src/bashdb-4.4-0.92
  _manifest shell/bashdb $src \
    $(find $src -name '*.sh' -a -printf '%P\n')

  src=~/git/other/Bash-Snippets
  _manifest "shell/$(basename $src)" $src \
    $(find $src \
      \( -name .git -a -prune \) -o \
      \( -type f -a -executable -a -printf '%P\n' \) )

  # ASDF meta package/version manager.
  # Note that the language-specific plugins are specified (as remote repos)
  # here: https://github.com/asdf-vm/asdf-plugins/tree/master/plugins
  # They # could be used for more tests.

  src=~/git/other/asdf
  _manifest "shell/$(basename $src)" $src \
    $(find $src \( -name '*.sh' -o -name '*.bash' \) -a -printf '%P\n' )

  src=~/git/other/scripts-to-rule-them-all
  _manifest "shell/$(basename $src)" $src \
    $(find $src \
      \( -name .git -a -prune \) -o \
      \( -type f -a -executable -a -printf '%P\n' \) )

  _sh-manifest ~/git/other/modernish shell
  _sh-manifest ~/git/other/posixcube shell

  # Shells themselves
  _sh-manifest ~/git/other/ast shell  # korn shell stuff
  _sh-manifest ~/git/other/mwc-sh shell
  _sh-manifest ~/src/mksh shell

  #
  # Linux Distros
  #

  _sh-manifest ~/git/other/minimal distro
  _sh-manifest ~/git/other/linuxkit distro
  _sh-manifest ~/git/other/portage distro

  src=~/git/alpine/aports
  _manifest distro/alpine-aports $src \
    $(find $src -name APKBUILD -a -printf '%P\n')

  src=$ABORIGINAL_DIR
  _manifest distro/aboriginal $src \
    $(find $src -name '*.sh' -printf '%P\n')

  src=/etc/init.d
  _manifest distro/initd $src \
    $(find $src -type f -a -executable -a -printf '%P\n')

  src=/usr/bin
  _manifest distro/usr-bin $src \
    $(find $src -name '*.sh' -a -printf '%P\n')

  # Version 1.0.89 extracts to a version-less dir.
  src=~/git/basis-build/_tmp/debootstrap
  _manifest distro/debootstrap $src \
    $(find $src '(' -name debootstrap -o -name functions ')' -a -printf '%P\n') \
    $(find $src/scripts -type f -a -printf 'scripts/%P\n')

  #
  # Operating Systems
  #

  _sh-manifest ~/git/other/minix
  _sh-manifest ~/git/other/illumos-gate
  _sh-manifest ~/git/other/daemontools-encore

  #
  # Cloud Stuff
  #
  _sh-manifest ~/git/other/mesos cloud
  _sh-manifest ~/git/other/rocket cloud
  _sh-manifest ~/git/other/docker cloud
  _sh-manifest ~/git/other/chef-bcpc cloud
  _sh-manifest ~/git/other/sandstorm cloud
  _sh-manifest ~/git/other/kubernetes cloud
  _sh-manifest ~/git/other/manta-marlin cloud

  src=~/git/other/dokku
  _manifest cloud/dokku $src \
    $(find $src '(' -name '*.sh' -o -name dokku ')' -a -printf '%P\n')

  #
  # Google
  #
  _sh-manifest ~/git/other/bazel google
  _sh-manifest ~/git/other/protobuf google
  _sh-manifest ~/git/other/kythe google
  _sh-manifest ~/git/other/tensorflow google
  # Filenames with spaces!
  #_sh-manifest ~/git/other/grpc google

  #
  # Esoteric
  #

  _sh-manifest ~/git/scratch/shasm esoteric
  _sh-manifest ~/git/wild/esoteric/wwwoosh esoteric
  _sh-manifest ~/git/wild/esoteric/lishp esoteric

  src=~/git/wild/esoteric/mal/bash
  _manifest esoteric/make-a-lisp-bash $src \
    $(find $src '(' -name '*.sh' ')' -a -printf '%P\n')

  src=~/git/wild/esoteric/gherkin
  _manifest esoteric/gherkin $src \
    $(find $src '(' -name '*.sh' -o -name 'gherkin' ')' -a -printf '%P\n')

  src=~/git/wild/esoteric/balls
  _manifest esoteric/balls $src \
    $(find $src '(' -name '*.sh' -o -name balls -o -name esh ')' -a \
                -printf '%P\n')

  src=~/git/wild/esoteric/bashcached
  _manifest esoteric/bashcached $src \
    $(find $src '(' -name '*.sh' -o -name 'bashcached' ')' -a -printf '%P\n')

  src=~/git/wild/esoteric/quinedb
  _manifest esoteric/quinedb $src \
    $(find $src '(' -name '*.sh' -o -name 'quinedb' ')' -a -printf '%P\n')

  src=~/git/wild/esoteric/bashttpd
  _manifest esoteric/bashttpd $src \
    $(find $src -name 'bashttpd' -a -printf '%P\n')

  # JSON Parsers
  src=~/git/other/j
  _manifest esoteric/j $src \
    $(find $src -type f -a  -name j -a -printf '%P\n')

  _sh-manifest ~/git/other/JSON.sh esoteric

  #
  # Other Languages
  #

  _sh-manifest ~/git/other/julia
  _sh-manifest ~/git/other/reason
  _sh-manifest ~/git/other/sdk  # Dart SDK?

  _sh-manifest ~/git/other/micropython
  _sh-manifest ~/git/other/staticpython  # statically linked build

  _sh-manifest ~/git/other/exp  # Go experimental repo

  #
  # Grab Bag
  #

  # This overlaps with git too much
  #src=~/git/other
  #local depth=3
  #_manifest git-other $src \
  #  $(find $src -maxdepth $depth -name '*.sh' -a -printf '%P\n')

  src=~/hg/other
  _manifest hg-other $src \
    $(find $src -name '*.sh' -a -printf '%P\n')

  #
  # Top-Level
  #

  # Kernel
  _sh-manifest ~/src/linux-4.8.7

  # Git
  # git-gui.sh and po2msg.sh are actually Tcl!  We could stop parsing at 'exec'
  # but there's no point right now.
  src=~/git/other/git
  _manifest $(basename $src) $src \
    $(find $src -name '*.sh' -a \
      ! -name 'git-gui.sh' \
      ! -name 'po2msg.sh' \
      -a -printf '%P\n')

  _sh-manifest ~/git/other/liballocs
  _sh-manifest ~/git/other/boringssl
  _sh-manifest ~/git/other/arrow

  #
  # Uncategorized
  #

  # Has filenames with spaces!
  #_sh-manifest ~/git/other/linguist

  # Brendan Gregg's performance scripts.
  # Find executable scripts, since they don't end in sh.
  # net/tcpretrans is written in Perl.
  src=~/git/other/perf-tools
  _manifest $(basename $src) $src \
    $(find $src \
      \( -name .git -a -prune \) -o \
      \( -name tcpretrans -a -prune \) -o \
      \( -type f -a -executable -a -printf '%P\n' \) )

  # Most of these scripts have no extension.  So look at executable ones and
  # then see if the shebang ends with sh!

  # NOTE: In Oil it would be nice if shebang-is-shell could be a function call.
  # Don't need to fork every time.
  src=~/git/other/pixelb-scripts
  _manifest pixelb-scripts $src \
    $(find $src \( -name .git -a -prune \) -o \
                \( -type f -a \
                   -executable -a \
                   ! -name '*.py' -a \
                   -exec test/shebang.sh is-shell {} ';' -a \
                   -printf '%P\n' \) )

  # Something related to WebDriver
  # Doesn't parse because of extended glob.
  src=~/git/other/wd
  _manifest $(basename $src) $src \
    $(find $src -type f -a  -name wd -a -printf '%P\n')

  #
  # Big
  #

  return
  log "Finding Files in Big Projects"
  readonly BIG_BUILD_ROOT=/media/andy/hdd-8T/big-build/ssd-backup/sdb/build

  # 2m 18s the first time.
  # 2 seconds the second time.  This is a big slow drive.
  time {
    _sh-manifest $BIG_BUILD_ROOT/hg/other/mozilla-central/

    _sh-manifest $BIG_BUILD_ROOT/chrome
    _configure-manifest $BIG_BUILD_ROOT/chrome

    _sh-manifest $BIG_BUILD_ROOT/android
    _configure-manifest $BIG_BUILD_ROOT/android

    _sh-manifest $BIG_BUILD_ROOT/openwrt
    _sh-manifest $BIG_BUILD_ROOT/OpenWireless
  }
}

# TODO: Parameterize this; it's duplicated in wild-runner.txt.
readonly MANIFEST=_tmp/wild/MANIFEST.txt

write-manifest() {
  mkdir -p _tmp/wild
  local out=$MANIFEST
  all-manifests > $out
  wc -l $out
}

# 442K lines without "big" and without ltmain.sh
# TODO: Include a few ltmain.sh.  Have to de-dupe them.
#
# 767K lines with aports (It's 250K lines by itself.)

# 1.30 M lines with "big".
# 760K lines without ltmain.sh.  Hm need to get up to 1M.

abspaths() {
  local proj=${1:-}
  if test -n "$proj"; then
    awk -v proj=$proj '$1 == proj {print $2}' $MANIFEST
  else
    awk '{print $2}' $MANIFEST
  fi
}

# Excluding ltmain.sh, goes from 910K lines to 830K.
count-lines() {
  # We need this weird --files0-from because there are too many files.  xargs
  # would split it into multiple invocations.
  #
  # It would be nicer if wc just had an option not to sum?
  time abspaths | 
    grep -v ltmain.sh |
    tr '\n' '\0' | wc -l --files0-from - | sort -n
}

# Takes ~15 seconds for 8,000+ files.
#
# NOTE: APKBUILD don't have shebang lines!  So there are a bunch of false
# detections, e.g. APKBUILD as Makefile, C, etc.
detect-all-types() {
  time abspaths | xargs file | pv > _tmp/wild/file-types.txt
}

wild-types() {
  cat _tmp/wild/file-types.txt | test/wild_types.py
}

# Make a report for all, but only run some
all() {
  test/wild-runner.sh parse-and-report "$@"
}

#
# Find Biggest Shell Scripts in Aboriginal Source Tarballs
#

readonly AB_PACKAGES=~/hg/scratch/aboriginal/aboriginal-1.2.2/packages

aboriginal-packages() {
  for z in $AB_PACKAGES/*.tar.gz; do
    local name=$(basename $z .tar.gz)
    echo $z -z $name
  done
  for z in $AB_PACKAGES/*.tar.bz2; do
    local name=$(basename $z .tar.bz2)
    echo $z -j $name
  done
}

readonly AB_OUT=_tmp/aboriginal

aboriginal-manifest() {
  mkdir -p $AB_OUT

  aboriginal-packages | while read z tar_flag name; do
    echo $z $name
    local listing=$AB_OUT/${name}.txt
    tar --list --verbose $tar_flag < $z | grep '\.sh$' > $listing || true
  done
}

aboriginal-biggest() {
  # print size and filename
  cat $AB_OUT/*.txt | awk '{print $3 " " $6}' | sort -n
}

# biggest scripts besides ltmain:
#
# 8406 binutils-397a64b3/binutils/embedspu.sh
# 8597 binutils-397a64b3/ld/emulparams/msp430all.sh
# 9951 bash-2.05b/examples/scripts/dd-ex.sh
# 12558 binutils-397a64b3/ld/genscripts.sh
# 14148 bash-2.05b/examples/scripts/adventure.sh
# 21811 binutils-397a64b3/gas/testsuite/gas/xstormy16/allinsn.sh
# 28004 bash-2.05b/examples/scripts/bcsh.sh
# 29666 gcc-4.2.1/ltcf-gcj.sh
# 33972 gcc-4.2.1/ltcf-c.sh
# 39048 gcc-4.2.1/ltcf-cxx.sh

if test "$(basename $0)" = 'wild.sh'; then
  "$@"
fi

