#!/bin/bash
set -eu

MYDIR=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
readonly MYDIR

cd ${MYDIR}

(
rm -rf MPAS-Model
git clone https://github.com/MPAS-Dev/MPAS-Model.git
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
