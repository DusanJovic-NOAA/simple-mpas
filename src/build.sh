#/usr/bin/bash
set -eux

MYDIR=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
readonly MYDIR

export NETCDF=${NetCDF_ROOT}
export PATH=${NetCDF_ROOT}/bin:${PATH}

(
cd MPAS-Model
rm -rf build install
mkdir build
cd build
cmake .. -DMPAS_CORES='atmosphere init_atmosphere' -DCMAKE_INSTALL_PREFIX=../install -DBUILD_SHARED_LIBS=OFF
make -j8
make install
)

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

ls -l MPAS-Model/install/bin/mpas_atmosphere MPAS-Model/install/bin/mpas_init_atmosphere
ls -l WPS/ungrib.exe
ls -l MPAS-Tools/mesh_tools/grid_rotate/grid_rotate
ls -l convert_mpas/convert_mpas
