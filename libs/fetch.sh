#!/bin/bash

OS=$(uname -s)

download_and_check_md5sum() {
    local -r HASH="$1"
    local -r URL="$2"
    local -r FILE="$(basename "$URL")"
    local -r OUT_FILE="${3:-$FILE}"

    local GREEN
    local RED
    local NC
    [[ -t 1 ]] && GREEN='\033[1;32m' || GREEN=''
    [[ -t 1 ]] && RED='\033[1;31m' || RED=''
    [[ -t 1 ]] && NC='\033[0m' || NC=''

    local MD5HASH=''
    if [[ -f "$OUT_FILE" ]]; then
        if [[ $OS == Darwin ]]; then
            MD5HASH=$(md5 "$OUT_FILE" 2> /dev/null | awk '{print $4}')
        else
            MD5HASH=$(md5sum "$OUT_FILE" 2> /dev/null | awk '{print $1}')
        fi
    fi
    if [[ "$MD5HASH" == "$HASH" ]]; then
        echo -e "$OUT_FILE ${GREEN}checksum OK${NC}"
    else
        rm -f "${OUT_FILE}"
        printf '%s' "Downloading $OUT_FILE "
        curl -f -k -s -S -R -L "$URL" -o "$OUT_FILE"
        if [[ -f "$OUT_FILE" ]]; then
            if [[ $OS == Darwin ]]; then
                MD5HASH=$(md5 "$OUT_FILE" 2> /dev/null | awk '{print $4}')
            else
                MD5HASH=$(md5sum "$OUT_FILE" 2> /dev/null | awk '{print $1}')
            fi
        fi
        if [[ "$MD5HASH" == "$HASH" ]]; then
            echo -e "${GREEN}checksum OK${NC}"
        else
            echo -e "${RED}incorrect checksum${NC}"
            exit 1
        fi
    fi
}

mkdir -p downloads
cd downloads || exit

download_and_check_md5sum 9c7d356c5acaa563555490676ca14d23  https://github.com/madler/zlib/archive/refs/tags/v1.2.13.tar.gz                           zlib.tar.gz

download_and_check_md5sum 73b513b9c40a8ca2913fcb38570ecdbd  https://github.com/HDFGroup/hdf5/archive/refs/tags/hdf5_1.14.6.tar.gz                     hdf5.tar.gz
download_and_check_md5sum 84acd096ab4f3300c20db862eecdf7c7  https://github.com/Unidata/netcdf-c/archive/v4.9.2.tar.gz                                 netcdf.tar.gz
download_and_check_md5sum 8c200fcf7d9d2761037dfd2dabe2216b  https://github.com/Unidata/netcdf-fortran/archive/v4.6.1.tar.gz                           netcdf_fortran.tar.gz

download_and_check_md5sum a3c39f002a7a81882b65b7eb8c9a7d91  https://github.com/CESM-Development/CMake_Fortran_utils/archive/refs/tags/CMake_Fortran_utils_150308.tar.gz cmake_fortran_utils.tar.gz
download_and_check_md5sum bb4552a07eadb6c5a54677f96282489d  https://parallel-netcdf.github.io/Release/pnetcdf-1.12.3.tar.gz                           pnetcdf.tar.gz
download_and_check_md5sum 7f3504dfb5aab846f4a9018dda7bb8ad  https://github.com/PARALLELIO/genf90/archive/refs/tags/genf90_200608.tar.gz               genf90.tar.gz
download_and_check_md5sum b16e88125fbb7e5bd06e8f392f91ae26  https://github.com/NCAR/ParallelIO/archive/refs/tags/pio2_6_2.tar.gz                      pio.tar.gz

download_and_check_md5sum e4fa27d720c323db600a42b65d4f20f7  https://github.com/esmf-org/esmf/archive/refs/tags/v8.9.0.tar.gz                          esmf.tar.gz

download_and_check_md5sum 95bab417fbaf7c1f6f99316052189bea  https://github.com/NOAA-EMC/NCEPLIBS-bacio/archive/refs/tags/v2.4.1.tar.gz                bacio.tar.gz
download_and_check_md5sum fc50806fb552b114a9f18d57ad3747a7  https://github.com/NOAA-EMC/NCEPLIBS-sp/archive/refs/tags/v2.5.0.tar.gz                   sp.tar.gz
download_and_check_md5sum ab162725c04899b8295bd74ed184debf  https://github.com/NOAA-EMC/NCEPLIBS-w3emc/archive/refs/tags/v2.12.0.tar.gz               w3emc.tar.gz

curl -f -k -s -S -R -L https://github.com/KarypisLab/GKlib/archive/refs/heads/master.tar.gz  -o  gklib.tar.gz
curl -f -k -s -S -R -L https://github.com/KarypisLab/METIS/archive/refs/tags/v5.2.1.tar.gz   -o  metis.tar.gz
