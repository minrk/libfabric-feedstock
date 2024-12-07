#!/bin/bash

set -ex

# verify ABI version
ABI_LINE=$(grep '#define\s\+CURRENT_ABI' include/ofi_abi.h)
echo "ABI_LINE=${ABI_LINE}"

CURRENT_ABI=$(echo "$ABI_LINE" | grep -o 'FABRIC_[[:digit:]\.]\+')
echo "CURRENT_ABI=${CURRENT_ABI}"

if [[ "$CURRENT_ABI" != "FABRIC_$LIBFABRIC_ABI" ]]; then
  echo "CURRENT_ABI=${CURRENT_ABI} != FABRIC_${$LIBFABRIC_ABI}"
  exit 1
fi

build_with_libnl=""
if [[ "$target_platform" == linux-* ]]; then
  echo "Build with libnl support"
  build_with_libnl=" --with-libnl=$PREFIX "
fi

if [[ "$target_platform" == osx-arm64 ]]; then
  # fix outdated config.sub on mac arm
  echo 'echo arm64-apple-darwin' > config/config.sub
fi

./configure \
    --prefix=$PREFIX \
    --docdir=$PWD/noinst/doc \
    --mandir=$PWD/noinst/man \
    $build_with_libnl \
    --disable-static \
    --disable-psm3 \
    --disable-opx

make -j"${CPU_COUNT}"

if [[ "$target_platform" == linux-* ]]; then
  make check
fi

make install

