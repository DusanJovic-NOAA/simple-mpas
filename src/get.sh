#!/bin/bash
set -eu

MYDIR=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
readonly MYDIR

cd ${MYDIR}

(
rm -rf MPAS-Model-ncar
git clone https://github.com/MPAS-Dev/MPAS-Model.git MPAS-Model-ncar
)

(
rm -rf MPAS-Model-gsl
git clone --recursive https://github.com/ufs-community/MPAS-Model MPAS-Model-gsl

sed -i -e 's/valm = dotProduct(velCellp/valm = dotProduct(velCellm/g' MPAS-Model-gsl/src/core_atmosphere/diagnostics/mpas_pv_diagnostics.F
)

(
rm -rf WPS
git clone https://github.com/wrf-model/WPS.git
)

(
rm -rf MPAS-Tools
git clone https://github.com/MPAS-Dev/MPAS-Tools.git
)

(
rm -rf convert_mpas
git clone https://github.com/mgduda/convert_mpas.git
)

(
rm -rf MPAS-Limited-Area
git clone https://github.com/MPAS-Dev/MPAS-Limited-Area.git
)

(
rm -rf MPASSIT
git clone https://github.com/LarissaReames/MPASSIT.git
)

(
rm -rf ufs-weather-model
git clone --recursive --jobs 8 --branch ufs_with_mpasmodel https://github.com/DusanJovic-NOAA/ufs-weather-model

cd ufs-weather-model/UFSATM
git checkout ufs_with_mpasmodel

cd mpasmodel/MPAS-Model
git checkout ufs_with_mpasmodel

git clone -b 20250616-MPASv8.3 https://github.com/NCAR/MMM-physics src/core_atmosphere/physics/physics_mmm
git clone -b MPAS_20241223     https://github.com/NOAA-GSL/UGWP.git src/core_atmosphere/physics/physics_noaa/UGWP
)

(
cd standalone-ext-esmf
./clone.sh
)
