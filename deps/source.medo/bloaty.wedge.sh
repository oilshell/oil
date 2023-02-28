# Wedge definition for bloaty
#
# Loaded by deps/wedge.sh.

set -o nounset
set -o pipefail
set -o errexit

WEDGE_NAME='bloaty'
WEDGE_VERSION='1.1'

wedge-build() {
  local src_dir=$1
  local build_dir=$2
  local install_dir=$3

  pushd $build_dir

  # It's much slower without -G Ninja!
  # TODO: Ninja is not in the wedge-builder
  # time cmake -G Ninja -DCMAKE_INSTALL_PREFIX=$install_dir $src_dir

  # Limit parallelism.  This build is ridiculously expensive?
  # time ninja -j 4

  time cmake -DCMAKE_INSTALL_PREFIX=$install_dir $src_dir

  time make -j 4

  popd
}

wedge-install() {
  local build_dir=$1
  local install_dir=$2

  pushd $build_dir

  # Uh, this includes 500 MB of the bloated protobuf compiler, as static
  # libraries and binaries
  # time make install

  # So let's just copy the executable
  mkdir -p $install_dir

  # 45 MB without stripping
  # cp -v $build_dir/bloaty $install_dir/bloaty

  # 6 MB after stripping
  strip -o $install_dir/bloaty \
    $build_dir/bloaty 

  popd
}

wedge-smoke-test() {
  local install_dir=$1

  $install_dir/bloaty --help
}
