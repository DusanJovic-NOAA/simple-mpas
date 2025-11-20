#!/bin/bash
set -eu
# set -x

source configuration.sh

mkdir -p "${FIX_DATA}/meshes"
(
cd ${FIX_DATA}/meshes
if [[ ! -f x1.${RES}.tar.gz ]]; then
  wget https://www2.mmm.ucar.edu/projects/mpas/atmosphere_meshes/x1.${RES}.tar.gz
  tar xf x1.${RES}.tar.gz
fi
)

(
cd ${FIX_DATA}/meshes
if [[ ! -f x1.${RES}_static.tar.gz ]]; then
  wget https://www2.mmm.ucar.edu/projects/mpas/atmosphere_meshes/x1.${RES}_static.tar.gz
  tar xf x1.${RES}_static.tar.gz
fi
)

(
if [[ ! $grid == "global" ]]; then
cd ${FIX_DATA}
if [[ ! -f mpas_static.tar.bz2 ]]; then
  wget https://www2.mmm.ucar.edu/projects/mpas/mpas_static.tar.bz2
  tar xf mpas_static.tar.bz2
fi
fi
)

echo "Done!"
