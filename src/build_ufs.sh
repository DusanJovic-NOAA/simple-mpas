#/usr/bin/bash
set -eux

MYDIR=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
readonly MYDIR

(
cd ufs-weather-model
rm -rf build_mpas
CMAKE_FLAGS='-DAPP=MPASMODEL -D32BIT=ON -DDEBUG=OFF' BUILD_DIR=build_mpas BUILD_VERBOSE=1 ./build.sh
)
