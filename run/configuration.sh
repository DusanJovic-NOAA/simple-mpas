
smw=$( cd $(pwd)/.. ; pwd -P )

RES=10242  # 240km
# RES=40962  # 120km
# RES=1024002  # 24km
TASKS=12

grid=global
# grid=conus

if [[ ${grid} == "global" ]]; then
  MGRID=x1.${RES}
else
  MGRID=${grid}
fi

START_YEAR=${START_YEAR:-$(date --date="1 day ago" --utc +%Y)}
START_MONTH=${START_MONTH:-$(date --date="1 day ago" --utc +%m)}
START_DAY=${START_DAY:-$(date --date="1 day ago" --utc +%d)}
START_HOUR=${START_HOUR:-00}

START_YEAR=2025
START_MONTH=11
START_DAY=06
START_HOUR=00

STOP_YEAR=2025
STOP_MONTH=11
STOP_DAY=08
STOP_HOUR=00

NHOURS_FCST=48
BC_INT=24

FIX_DATA=$(pwd)/fix_data
INPUT_DATA=$(pwd)/input_data
GEOG_DATA_PATH="${FIX_DATA}/mpas_static"

INPUT_TYPE=grib2

MPI_IMPLEMENTATION=${MPI_IMPLEMENTATION:-mpich}
mpiexec --version | grep OpenRTE 2> /dev/null && MPI_IMPLEMENTATION=openmpi
mpiexec --version | grep "Open MPI" 2> /dev/null && MPI_IMPLEMENTATION=openmpi
mpiexec --version | grep Intel 2> /dev/null && MPI_IMPLEMENTATION=intelmpi

if [[ $MPI_IMPLEMENTATION == openmpi ]]; then
  # Get rid of Read -1, expected <someNumber>, errno =1 error
  # See https://github.com/open-mpi/ompi/issues/4948
  export OMPI_MCA_btl_vader_single_copy_mechanism=none
  MPIEXEC='mpiexec --oversubscribe'
else
  MPIEXEC='mpiexec'
fi
MPIEXEC=srun

eparse() { ( set -eu; set +x; eval "set -eu; cat<<_EOF"$'\n'"$(< "$1")"$'\n'"_EOF"; ) }
