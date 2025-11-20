#!/bin/bash
set -eux

# if [[ $(uname -s) == Linux ]]; then
# ulimit -s unlimited
# fi

source configuration.sh

MYDIR=$(pwd)/static_run

rm -rf ${MYDIR}
mkdir -p ${MYDIR}
cd ${MYDIR}

if [[ -e "${FIX_DATA}/meshes/x1.${RES}.static.nc" ]]; then

  ln -sf ${FIX_DATA}/meshes/x1.${RES}.static.nc .

else

  MPAS_MODEL=${smw}/src/MPAS-Model

  ln -s ${smw}/run/fix_data/meshes/x1.${RES}.grid.nc .
  ln -s ${smw}/run/fix_data/meshes/x1.${RES}.graph.info.part.${TASKS} .

  export GEOG_DATA_PATH="${FIX_DATA}/mpas_static"

  INIT_CASE=7  # static

  CONFIG_STATIC_INTERP=true
  CONFIG_NATIVE_GWD_STATIC=true

  eparse ${smw}/run/parm/namelist.init_atmosphere.IN > namelist.init_atmosphere
  eparse ${smw}/run/parm/streams.static.init_atmosphere.IN  > streams.init_atmosphere

  ln -sf ${MPAS_MODEL}/install/bin/mpas_init_atmosphere .

  ${MPIEXEC} -n ${TASKS} ./mpas_init_atmosphere

fi

echo 'Done!'
