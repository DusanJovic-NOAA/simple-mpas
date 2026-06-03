#!/bin/bash
set -eux

MYDIR=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
readonly MYDIR

export NETCDF=${netcdf_c_ROOT}
export PATH=${NETCDF}/bin:${PATH}

(
cd WPS
echo 1 | ./configure --nowrf --build-grib2-libs
./compile ungrib
ls -l ungrib.exe
)

(
cd MPAS-Tools/mesh_tools/grid_rotate
make
ls -l grid_rotate
)

(
cd convert_mpas
make
ls -l convert_mpas
)

(
cd MPAS-Limited-Area
)

(
cd MPASSIT
rm -rf build install
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=../install # -DCMAKE_BUILD_TYPE=Debug
make -j8
make install
)

ls -l WPS/ungrib.exe
ls -l MPAS-Tools/mesh_tools/grid_rotate/grid_rotate
ls -l convert_mpas/convert_mpas
ls -l MPASSIT/install/bin/mpassit

