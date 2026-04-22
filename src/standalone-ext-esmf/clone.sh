#!/bin/bash

git clone --branch v8.4.0 https://github.com/MPAS-Dev/MPAS-Model MPAS-Model

sed -i -e 's/-DMPAS_NO_ESMF_INIT//g' MPAS-Model/CMakeLists.txt

sed -i -e 's/ALIAS esmf/ALIAS ESMF::ESMF/g' MPAS-Model/CMakeLists.txt

sed -i -e 's/valm = dotProduct(velCellp/valm = dotProduct(velCellm/g' MPAS-Model/src/core_atmosphere/diagnostics/mpas_pv_diagnostics.F

sed -i -e '/external::esmf/ s/./#&/' MPAS-Model/src/tools/registry/CMakeLists.txt

sed -i -e '/if(MPAS_OPENMP)/a\' -e '        list(APPEND MPAS_FORTRAN_TARGET_COMPILE_DEFINITIONS MPAS_OPENMP=1)' MPAS-Model/cmake/Functions/MPAS_Functions.cmake
