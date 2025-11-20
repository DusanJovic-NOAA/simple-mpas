#!/bin/bash
set -eux

# if [[ $(uname -s) == Linux ]]; then
# ulimit -s unlimited
# fi

source configuration.sh

MYDIR=$(pwd)/model_run

rm -rf ${MYDIR}
mkdir -p ${MYDIR}
cd ${MYDIR}

MPAS_MODEL=${smw}/src/MPAS-Model

ln -s ${MPAS_MODEL}/install/share/MPAS/core_atmosphere/CAM_ABS_DATA.DBL .
ln -s ${MPAS_MODEL}/install/share/MPAS/core_atmosphere/CAM_AEROPT_DATA.DBL .
ln -s ${MPAS_MODEL}/install/share/MPAS/core_atmosphere/GENPARM.TBL .
ln -s ${MPAS_MODEL}/install/share/MPAS/core_atmosphere/LANDUSE.TBL .
ln -s ${MPAS_MODEL}/install/share/MPAS/core_atmosphere/OZONE_DAT.TBL .
ln -s ${MPAS_MODEL}/install/share/MPAS/core_atmosphere/OZONE_LAT.TBL .
ln -s ${MPAS_MODEL}/install/share/MPAS/core_atmosphere/OZONE_PLEV.TBL .
ln -s ${MPAS_MODEL}/install/share/MPAS/core_atmosphere/RRTMG_LW_DATA .
ln -s ${MPAS_MODEL}/install/share/MPAS/core_atmosphere/RRTMG_LW_DATA.DBL .
ln -s ${MPAS_MODEL}/install/share/MPAS/core_atmosphere/RRTMG_SW_DATA .
ln -s ${MPAS_MODEL}/install/share/MPAS/core_atmosphere/RRTMG_SW_DATA.DBL .
ln -s ${MPAS_MODEL}/install/share/MPAS/core_atmosphere/SOILPARM.TBL .
ln -s ${MPAS_MODEL}/install/share/MPAS/core_atmosphere/VEGPARM.TBL .

if [[ ${grid} == "global" ]]; then
  ln -s ${smw}/run/real_run/${MGRID}.sfc_update.nc .
  APPLY_LBCS=false
  MGRID=x1.${RES}
else
  ln -s ${smw}/run/real_run/lbc.*.nc .
  MGRID=${grid}
  APPLY_LBCS=true
fi

ln -s ${smw}/run/real_run/${MGRID}.graph.info.part.${TASKS} .
ln -s ${smw}/run/real_run/${MGRID}.init.nc .

RUN_DURATION_DAYS=$(( NHOURS_FCST/24 ))
RUN_DURATION_HOURS=$(( NHOURS_FCST%24 ))

DT=600
# DT=120  # 24km

eparse ${smw}/run/parm/namelist.atmosphere.IN > namelist.atmosphere
eparse ${smw}/run/parm/streams.atmosphere.IN  > streams.atmosphere

cp ${MPAS_MODEL}/install/share/MPAS/core_atmosphere/stream_list.atmosphere.* .

ln -sf ${MPAS_MODEL}/install/bin/mpas_atmosphere .

${MPIEXEC} -n ${TASKS} ./mpas_atmosphere

echo 'Done!'
