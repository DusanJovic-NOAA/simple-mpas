#!/bin/bash
set -eux

source configuration.sh

MYDIR=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
readonly MYDIR

rm -rf ${INPUT_DATA}
mkdir ${INPUT_DATA}
cd ${INPUT_DATA}

YYYYMMDD=${START_YEAR}${START_MONTH}${START_DAY}
CC=${START_HOUR}

GFS_PROD='https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod'

if [[ $INPUT_TYPE == grib2 ]]; then

  curl -f -s -S -R -L -O ${GFS_PROD}/gfs.${YYYYMMDD}/${CC}/atmos/gfs.t${CC}z.pgrb2.0p50.f000

  for FHR in $(seq -s ' ' -f %03g $BC_INT $BC_INT $NHOURS_FCST); do
    curl -f -s -S -R -L -O ${GFS_PROD}/gfs.${YYYYMMDD}/${CC}/atmos/gfs.t${CC}z.pgrb2.0p50.f${FHR}
  done

else

  echo "Unknown INPUT_TYPE ${INPUT_TYPE}"
  exit 1

fi
