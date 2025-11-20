#!/bin/bash
set -eux

MYDIR=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
readonly MYDIR

cd "${MYDIR}"

source configuration.sh

./run_static.sh

if [[ ! ${grid} == 'global' ]];  then
  ./run_regional.sh
fi

./run_ungrib.sh

./run_real.sh

./run_model.sh

echo 'Done!'
