#!/bin/bash
set -u
set -o pipefail

usage() {
  echo "Usage: $0 gnu | intel | intel_llvm [-all] [-libs] [-model] [-model_ufs] [-model_ext_esmf]"
  exit 1
}

[[ $# -lt 2 ]] && usage

export COMPILER=$1
shift

if [[ $(command -v ftn) && -n ${CRAYPE_VERSION} ]]; then
    # Special case on Cray systems with Cray PE
    echo "Cray with Cray PE ${CRAYPE_VERSION}"
    export CC=${CC:-cc}
    export CXX=${CXX:-CC}
    export FC=${FC:-ftn}
    export MPICC=${CC}
    export MPICXX=${CXX}
    export MPIF90=${FC}
else
  if [[ $COMPILER == gnu ]]; then
    export CC=${CC:-gcc}
    export CXX=${CXX:-g++}
    export FC=${FC:-gfortran}
    export MPICC=${MPICC:-mpicc}
    export MPICXX=${MPICXX:-mpicxx}
    export MPIF90=${MPIF90:-mpif90}
  elif [[ $COMPILER == intel ]]; then
    export CC=${CC:-icc}
    export CXX=${CXX:-icpc}
    export FC=${FC:-ifort}
    export MPICC=${MPICC:-mpiicc}
    export MPICXX=${MPICXX:-mpiicpc}
    export MPIF90=${MPIF90:-mpiifort}
  elif [[ $COMPILER == intel_llvm ]]; then
    export CC=${CC:-icx}
    export CXX=${CXX:-icpx}
    export FC=${FC:-ifx}
    export MPICC=${MPICC:-mpiicx}
    export MPICXX=${MPICXX:-mpiicpx}
    export MPIF90=${MPIF90:-mpiifx}
    export I_MPI_CC=${CC}
    export I_MPI_CXX=${CXX}
    export I_MPI_F90=${FC}
  else
    usage
  fi
fi

BUILD_LIBS=no
BUILD_MODEL=no
BUILD_MODEL_UFS=no
BUILD_MODEL_EXT_ESMF=no

while [[ $# -gt 0 ]]; do
opt=$1

case $opt in
  -all)
    BUILD_LIBS=yes
    BUILD_MODEL=yes
    BUILD_MODEL_UFS=yes
    BUILD_MODEL_EXT_ESMF=yes
    shift
    ;;
  -libs)
    BUILD_LIBS=yes
    shift
    ;;
  -model)
    BUILD_MODEL=yes
    shift
    ;;
  -model_ufs)
    BUILD_MODEL_UFS=yes
    shift
    ;;
  -model_ext_esmf)
    BUILD_MODEL_EXT_ESMF=yes
    shift
    ;;
  *)
    echo "unknown option ${opt}"
    usage
esac
done

echo "BUILD_LIBS           = ${BUILD_LIBS}"
echo "BUILD_MODEL          = ${BUILD_MODEL}"
echo "BUILD_MODEL_UFS      = ${BUILD_MODEL_UFS}"
echo "BUILD_MODEL_EXT_ESMF = ${BUILD_MODEL_EXT_ESMF}"

MYDIR=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
readonly MYDIR

export OMPI_CC=${CC}
export OMPI_CXX=${CXX}
export OMPI_FC=${FC}

# print compiler version
echo
echo "CC = ${CC}"
echo "CXX = ${CXX}"
echo "FC = ${FC}"
which ${CC}
which ${CXX}
which ${FC}
${CC} --version | head -1
${CXX} --version | head -1
${FC} --version | head -1
echo
echo "MPICC = ${MPICC}"
echo "MPICXX = ${MPICXX}"
echo "MPIF90 = ${MPIF90}"
which ${MPICC}
which ${MPICXX}
which ${MPIF90}
${MPICC} --version | head -1
${MPICXX} --version | head -1
${MPIF90} --version | head -1
echo
cmake --version | head -1
echo

#
# libs
#
if [ $BUILD_LIBS == yes ]; then
SECONDS=0
printf '%-.30s ' "Building libs ............................."
(
  cd ${MYDIR}/libs

  rm -rf build install
  mkdir build
  cd build

  cmake .. -DCMAKE_INSTALL_PREFIX=../install

  make -j 8

  cd ${MYDIR}/libs
  ./build_metis.sh ${COMPILER}

) > log_libs 2>&1
status=$?
  if [ $status -eq 0 ]; then
printf 'done [%4d sec]\n' ${SECONDS}
  else
    printf 'FAILED [%4d sec]\n' ${SECONDS}
    echo
    echo "---------------------------------------------------------------"
    echo "--- log_libs"
    cat log_libs
    echo "---------------------------------------------------------------"
    for f in libs/build/*-prefix/src/*-stamp/*-*-err.log; do
      echo
      echo "---------------------------------------------------------------"
      echo "--- $f"
      cat $f
      echo "---------------------------------------------------------------"
    done
    exit 1
  fi
fi

export CC=${MPICC}
export CXX=${MPICXX}
export FC=${MPIF90}

ufslibs_install_prefix=${MYDIR}/libs/install

export ZLIB_ROOT=${ufslibs_install_prefix}/zlib
export NetCDF_ROOT=${ufslibs_install_prefix}/netcdf
export netcdf_c_ROOT=${NetCDF_ROOT}  # compatibility with spack-stack
export PnetCDF_ROOT=${ufslibs_install_prefix}/pnetcdf
export PIO_ROOT=${ufslibs_install_prefix}/pio

export ESMF_ROOT=${ufslibs_install_prefix}/esmf

export bacio_ROOT=${ufslibs_install_prefix}/bacio
export sp_ROOT=${ufslibs_install_prefix}/sp
export w3emc_ROOT=${ufslibs_install_prefix}/w3emc

#
# model
#
if [ $BUILD_MODEL == yes ]; then
SECONDS=0
printf '%-.30s ' "Building model ..........................."
(
  cd src
  ./build.sh

) > log_model 2>&1
status=$?
  if [ $status -eq 0 ]; then
printf 'done [%4d sec]\n' ${SECONDS}
  else
    printf 'FAILED [%4d sec]\n' ${SECONDS}
    cat log_model
    exit 1
  fi
fi

#
# model_ufs
#
if [ $BUILD_MODEL_UFS == yes ]; then
SECONDS=0
printf '%-.30s ' "Building model_ufs ..........................."
(
  cd src
  ./build_ufs.sh

) > log_model_ufs 2>&1
status=$?
  if [ $status -eq 0 ]; then
printf 'done [%4d sec]\n' ${SECONDS}
  else
    printf 'FAILED [%4d sec]\n' ${SECONDS}
    cat log_model_ufs
    exit 1
  fi
fi

#
# model_ext_esmf
#
if [ $BUILD_MODEL_EXT_ESMF == yes ]; then
SECONDS=0
printf '%-.30s ' "Building model_ext_esmf ..........................."
(
  cd src/standalone-ext-esmf
  ./build.sh

) > log_model_ext_esmf 2>&1
status=$?
  if [ $status -eq 0 ]; then
printf 'done [%4d sec]\n' ${SECONDS}
  else
    printf 'FAILED [%4d sec]\n' ${SECONDS}
    cat log_model_ext_esmf
    exit 1
  fi
fi

echo "Done!"
