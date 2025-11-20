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
