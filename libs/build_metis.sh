#!/bin/bash
set -u
set -o pipefail

usage() {
  echo "Usage: $0 gnu | intel | intel_llvm "
  exit 1
}

[[ $# -lt 1 ]] && usage

export COMPILER=$1

if [[ $(command -v ftn) && -n ${CRAYPE_VERSION} ]]; then
    # Special case on Cray systems with Cray PE
    echo "Cray with Cray PE ${CRAYPE_VERSION}"
    export CC=${CC:-cc}
    export CXX=${CXX:-CC}
    export FC=${FC:-ftn}
else
  if [[ $COMPILER == gnu ]]; then
    export CC=${CC:-gcc}
    export CXX=${CXX:-g++}
    export FC=${FC:-gfortran}
  elif [[ $COMPILER == intel ]]; then
    export CC=${CC:-icc}
    export CXX=${CXX:-icpc}
    export FC=${FC:-ifort}
  elif [[ $COMPILER == intel_llvm ]]; then
    export CC=${CC:-icx}
    export CXX=${CXX:-icpx}
    export FC=${FC:-ifx}
  else
    usage
  fi
fi

MYDIR=$(dirname "$(realpath "$0")")
readonly MYDIR

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
cmake --version | head -1
echo

install_prefix=${MYDIR}/install
downloads_prefix=${MYDIR}/downloads


##
## GKlib
##
(
mkdir -p ${MYDIR}/build
cd ${MYDIR}/build

tar xvf ${downloads_prefix}/gklib.tar.gz
cd GKlib-master
rm -rf ${install_prefix}/gklib
make config prefix=${install_prefix}/gklib
make
make install
mkdir -p ${install_prefix}/gklib/lib/
mv ${install_prefix}/gklib/lib64/* ${install_prefix}/gklib/lib/
)

##
## METIS
##
(
mkdir -p ${MYDIR}/build
cd ${MYDIR}/build

rm -rf metis
mkdir metis
tar xvf ${downloads_prefix}/metis.tar.gz -C metis --strip-components=1

cd metis
rm -rf ${install_prefix}/metis
make config prefix=${install_prefix}/metis gklib_path=${install_prefix}/gklib
make
make install
)


















echo "Done!"
