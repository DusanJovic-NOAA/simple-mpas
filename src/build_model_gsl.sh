#!/bin/bash
set -eux

MYDIR=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
readonly MYDIR

export NETCDF=${netcdf_c_ROOT}
export PATH=${NETCDF}/bin:${PATH}

(
cd MPAS-Model-gsl
rm -rf build install
mkdir build
cd build

# Release both GNU and Intel
cmake .. -DMPAS_CORES='atmosphere init_atmosphere' -DCMAKE_INSTALL_PREFIX=../install -DMPAS_DOUBLE_PRECISION=OFF -DMPAS_USE_PIO=OFF -DBUILD_SHARED_LIBS=OFF -DMPAS_OPENMP=OFF -DCMAKE_BUILD_TYPE=Release

# GNU debug
# cmake .. -DMPAS_CORES='atmosphere init_atmosphere' -DCMAKE_INSTALL_PREFIX=../install -DMPAS_DOUBLE_PRECISION=OFF -DMPAS_USE_PIO=OFF -DBUILD_SHARED_LIBS=OFF -DMPAS_OPENMP=ON -DCMAKE_BUILD_TYPE=Debug -DCMAKE_Fortran_FLAGS_DEBUG="-ggdb -fbacktrace -cpp -O0 -fno-unsafe-math-optimizations -frounding-math -fsignaling-nans -ffpe-trap=invalid,zero,overflow -fbounds-check"

# Intel debug
# cmake .. -DMPAS_CORES='atmosphere init_atmosphere' -DCMAKE_INSTALL_PREFIX=../install -DMPAS_DOUBLE_PRECISION=OFF -DMPAS_USE_PIO=OFF -DBUILD_SHARED_LIBS=OFF -DMPAS_OPENMP=ON -DCMAKE_BUILD_TYPE=Debug -DCMAKE_Fortran_FLAGS_DEBUG="-g -traceback -fpp -O0 -check -check noarg_temp_created -warn -warn noerrors -fp-stack-check -fstack-protector-all -fpe0 -debug -ftrapuv -init=snan,arrays"

make -j8 VERBOSE=1
make install

# Generate Thompson cloud microphysics tables
# cd ../install/bin
# ./mpas_atmosphere_build_tables
# mv -i MP* ../share/MPAS/core_atmosphere/
)
