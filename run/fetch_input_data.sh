#!/bin/bash
set -eux

source configuration.sh

MYDIR=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
readonly MYDIR

rm -rf "${INPUT_DATA}"
mkdir "${INPUT_DATA}"
cd "${INPUT_DATA}"

YYYYMMDD=${START_YEAR}${START_MONTH}${START_DAY}
CC=${START_HOUR}

# GFS_PROD='https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod'
GFS_AWS='https://noaa-gfs-bdp-pds.s3.amazonaws.com'

# https://www.weather.gov/media/notification/pdf2/scn21-20gfs_v16.0_aac.pdf
readonly FIRST_GFSV16_CYCLE=2021032212

if [[ $INPUT_TYPE == grib2 ]]; then


   if [[ ${YYYYMMDD}${CC} -ge ${FIRST_GFSV16_CYCLE} ]]; then
      curl -f -s -S -R -L -O "${GFS_AWS}/gfs.${YYYYMMDD}/${CC}/atmos/gfs.t${CC}z.pgrb2.0p25.f000"
   else
      curl -f -s -S -R -L -O "${GFS_AWS}/gfs.${YYYYMMDD}/${CC}/gfs.t${CC}z.pgrb2.0p25.f000"
   fi

   for FHR in $(seq -s ' ' -f %03g $BC_INT $BC_INT $NHOURS_FCST); do
      if [[ ${YYYYMMDD}${CC} -ge ${FIRST_GFSV16_CYCLE} ]]; then
         curl -f -s -S -R -L -O "${GFS_AWS}/gfs.${YYYYMMDD}/${CC}/atmos/gfs.t${CC}z.pgrb2.0p25.f${FHR}"
      else
         curl -f -s -S -R -L -O "${GFS_AWS}/gfs.${YYYYMMDD}/${CC}/gfs.t${CC}z.pgrb2.0p25.f${FHR}"
      fi
   done

else

  echo "Unknown INPUT_TYPE ${INPUT_TYPE}"
  exit 1

fi
