#!/bin/bash
set -eux

# if [[ $(uname -s) == Linux ]]; then
# ulimit -s unlimited
# fi

source configuration.sh

MYDIR=$(pwd)/regional_run

rm -rf ${MYDIR}
mkdir -p ${MYDIR}
cd ${MYDIR}

cp ${smw}/run/parm/conus.custom.pts .

ln -s ${smw}/run/static_run/x1.${RES}.static.nc .

python3 ${smw}/src/MPAS-Limited-Area/create_region conus.custom.pts x1.${RES}.static.nc

${smw}/libs/install/metis/bin/gpmetis -minconn -contig -niter=200 conus.graph.info ${TASKS}

echo 'Done!'
