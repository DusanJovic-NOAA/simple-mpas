#!/bin/bash
set -eux

# if [[ $(uname -s) == Linux ]]; then
# ulimit -s unlimited
# fi

source configuration.sh

MYDIR=$(pwd)/real_run

rm -rf ${MYDIR}
mkdir -p ${MYDIR}
cd ${MYDIR}

MPAS_MODEL=${smw}/src/MPAS-Model

if [[ ${grid} == "global" ]]; then
  ln -s ${smw}/run/fix_data/meshes/x1.${RES}.grid.nc .
  ln -s ${smw}/run/fix_data/meshes/x1.${RES}.graph.info.part.${TASKS} .
  ln -s ${smw}/run/static_run/x1.${RES}.static.nc .
  MGRID=x1.${RES}
  BLEND_BDY_TERRAIN=false
else
  ln -s ${smw}/run/regional_run/${grid}.static.nc .
  ln -s ${smw}/run/regional_run/${grid}.graph.info* .
  MGRID=${grid}
  BLEND_BDY_TERRAIN=true
fi

FG_INTERVAL=$(( BC_INT * 3600))

ln -s ${smw}/run/ungrib_run/GFS:????-??-??_?? .

INIT_CASE=7  # static

CONFIG_VERTICAL_GRID=true
CONFIG_MET_INTERP=true
CONFIG_FRAC_SEAICE=true

eparse ${smw}/run/parm/namelist.init_atmosphere.IN > namelist.init_atmosphere
eparse ${smw}/run/parm/streams.real.init_atmosphere.IN  > streams.init_atmosphere

ln -sf ${MPAS_MODEL}/install/bin/mpas_init_atmosphere .

${MPIEXEC} -n ${TASKS} ./mpas_init_atmosphere

if [[ ${grid} == "global" ]]; then

# SST/surface
INIT_CASE=8  # sst

CONFIG_INPUT_SST=true

eparse ${smw}/run/parm/namelist.init_atmosphere.IN > namelist.init_atmosphere
eparse ${smw}/run/parm/streams.real.init_atmosphere.IN  > streams.init_atmosphere

${MPIEXEC} -n ${TASKS} ./mpas_init_atmosphere

else

# LBC
INIT_CASE=9  # lbc

CONFIG_VERTICAL_GRID=true
CONFIG_MET_INTERP=true
CONFIG_FRAC_SEAICE=true

eparse ${smw}/run/parm/namelist.init_atmosphere.IN > namelist.init_atmosphere
eparse ${smw}/run/parm/streams.real_lbc.init_atmosphere.IN  > streams.init_atmosphere

${MPIEXEC} -n ${TASKS} ./mpas_init_atmosphere

fi

echo 'Done!'
