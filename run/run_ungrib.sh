#!/bin/bash
set -eux

# if [[ $(uname -s) == Linux ]]; then
# ulimit -s unlimited
# fi

source configuration.sh

MYDIR=$(pwd)/ungrib_run

rm -rf ${MYDIR}
mkdir -p ${MYDIR}
cd ${MYDIR}

WPS=${smw}/src/WPS

ln -sf ${WPS}/ungrib/Variable_Tables/Vtable.GFS Vtable
${WPS}/link_grib.csh ${INPUT_DATA}/gfs*

export INTERVAL_SECONDS=$(( BC_INT * 3600 ))
eparse ${smw}/run/parm/namelist.wps.IN > namelist.wps

${WPS}/ungrib.exe &> log.ungrib

echo 'Done!'
