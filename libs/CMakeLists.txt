cmake_minimum_required(VERSION 3.24)

if(POLICY CMP0135)
  # DOWNLOAD_EXTRACT_TIMESTAMP
  cmake_policy(SET CMP0135 NEW)
endif()

project(ufs-libraries LANGUAGES C CXX Fortran)

include(ExternalProject)

set(MPI_DETERMINE_LIBRARY_VERSION true)
find_package(MPI REQUIRED C CXX Fortran)
message(STATUS "MPI find_package Found MPI_C_COMPILER = ${MPI_C_COMPILER}")
message(STATUS "MPI find_package Found MPI_CXX_COMPILER = ${MPI_CXX_COMPILER}")
message(STATUS "MPI find_package Found MPI_Fortran_COMPILER = ${MPI_Fortran_COMPILER}")

# Overwrite found mpi compiler wrappers
message(STATUS "CMAKE_VERSION = ${CMAKE_VERSION}")
set(CRAYPE_DETECTED FALSE)
if(DEFINED ENV{CRAYPE_VERSION})
  message("Cray PE detected")
  set(CRAYPE_DETECTED TRUE)
endif()
# FindMPI.cmake in CMake < 3.29.0 does not find IntelLLVM mpi wrappers. Set them explicitly
if (CMAKE_VERSION VERSION_LESS "3.29.0" AND ${CMAKE_Fortran_COMPILER_ID} MATCHES "IntelLLVM" AND NOT CRAYPE_DETECTED)
set(MPI_C_COMPILER mpiicx)
set(MPI_CXX_COMPILER mpiicpx)
set(MPI_Fortran_COMPILER mpiifx)
message(STATUS "Overwritten for IntelLLVM MPI_C_COMPILER = ${MPI_C_COMPILER}")
message(STATUS "Overwritten for IntelLLVM MPI_CXX_COMPILER = ${MPI_CXX_COMPILER}")
message(STATUS "Overwritten for IntelLLVM MPI_Fortran_COMPILER = ${MPI_Fortran_COMPILER}")
endif()

set(install_prefix ${CMAKE_INSTALL_PREFIX})

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

set(downloads_prefix "${CMAKE_CURRENT_SOURCE_DIR}/downloads")

##
## zlib
##
ExternalProject_Add(zlib
    URL ${downloads_prefix}/zlib.tar.gz
    URL_HASH MD5=9c7d356c5acaa563555490676ca14d23
    BUILD_IN_SOURCE ON
    CONFIGURE_COMMAND ./configure --prefix=${install_prefix}/zlib
                                  --libdir=${install_prefix}/zlib/lib
                                  --static
    LOG_DOWNLOAD ON
    LOG_CONFIGURE ON
    LOG_BUILD ON
    LOG_INSTALL ON
)

##
## hdf5
##
ExternalProject_Add(hdf5
    URL ${downloads_prefix}/hdf5.tar.gz
    URL_HASH MD5=73b513b9c40a8ca2913fcb38570ecdbd
    BUILD_IN_SOURCE OFF
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${install_prefix}/hdf5
               -DCMAKE_PREFIX_PATH=${install_prefix}
               -DCMAKE_BUILD_TYPE=Release
               -DBUILD_SHARED_LIBS=OFF
               -DBUILD_TESTING=OFF
               -DHDF5_BUILD_TOOLS=OFF
               -DHDF5_BUILD_UTILS=OFF
               -DHDF5_BUILD_CPP_LIB=OFF
               -DHDF5_BUILD_EXAMPLES=OFF
               -DHDF5_ENABLE_PARALLEL=ON
               -DHDF5_ENABLE_Z_LIB_SUPPORT=ON
               -DHDF5_USE_ZLIB_STATIC=ON
               -DHDF5_ENABLE_ZSTD_SUPPORT=OFF
               -DHDF5_ENABLE_SZIP_SUPPORT=OFF
               -DHDF5_ENABLE_LZ4_SUPPORT=OFF
               -DZLIB_ROOT=${install_prefix}/zlib
               -DHDF5_INSTALL_CMAKE_DIR=lib/cmake
    LOG_DOWNLOAD ON
    LOG_PATCH ON
    LOG_CONFIGURE ON
    LOG_BUILD ON
    LOG_INSTALL ON
)
ExternalProject_Add_StepDependencies(hdf5 build zlib)


##
## netcdf
##
if(NOT APPLE)
  set(_disable_libxml2 "--disable-libxml2")
endif()
ExternalProject_Add(netcdf
    URL ${downloads_prefix}/netcdf.tar.gz
    URL_HASH MD5=84acd096ab4f3300c20db862eecdf7c7
    BUILD_IN_SOURCE ON
    CONFIGURE_COMMAND env "CC=${MPI_C_COMPILER}"
                      env "CPPFLAGS=-I${install_prefix}/hdf5/include"
                      env "LDFLAGS=-L${install_prefix}/hdf5/lib -L${install_prefix}/zlib/lib"
                      env "LIBS=-lhdf5_hl -lhdf5 -lz -lm"
                      ./configure --prefix=${install_prefix}/netcdf
                                  --libdir=${install_prefix}/netcdf/lib
                                  --enable-cdf5
                                  --disable-dap
                                  --disable-nczarr
                                  --disable-nczarr-s3
                                  --disable-s3
                                  ${_disable_libxml2}
                                  --disable-byterange
                                  --enable-netcdf-4
                                  --disable-doxygen
                                  --disable-shared
                                  --enable-static
                                  --disable-large-file-tests
                                  --enable-parallel-tests
                                  --enable-logging
    LOG_DOWNLOAD ON
    LOG_CONFIGURE ON
    LOG_BUILD ON
    LOG_INSTALL ON
)
ExternalProject_Add_StepDependencies(netcdf build hdf5)

##
## netcdf_fortran
##
ExternalProject_Add(netcdf_fortran
    URL ${downloads_prefix}/netcdf_fortran.tar.gz
    URL_HASH MD5=8c200fcf7d9d2761037dfd2dabe2216b
    BUILD_IN_SOURCE ON
    CONFIGURE_COMMAND env "CC=${MPI_C_COMPILER}"
                      env "FC=${MPI_Fortran_COMPILER}"
                      env "CPPFLAGS=-I${install_prefix}/netcdf/include"
                      env "LDFLAGS=-L${install_prefix}/hdf5/lib -L${install_prefix}/netcdf/lib -L${install_prefix}/zlib/lib"
                      env "LIBS=-lnetcdf -lhdf5_hl -lhdf5 -lz -lm"
                      env "HDF5_PLUGIN_PATH=${install_prefix}/hdf5/lib/plugin"
                      ./configure --prefix=${install_prefix}/netcdf
                                  --libdir=${install_prefix}/netcdf/lib
                                  --enable-static
                                  --disable-shared
                                  --disable-doxygen
                                  --enable-zstandard_plugin
    LOG_DOWNLOAD ON
    LOG_CONFIGURE ON
    LOG_BUILD ON
    LOG_INSTALL ON
)
ExternalProject_Add_StepDependencies(netcdf_fortran build netcdf)

##
## genf90
##
ExternalProject_Add(genf90
    URL ${downloads_prefix}/genf90.tar.gz
    URL_HASH MD5=7f3504dfb5aab846f4a9018dda7bb8ad
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/genf90.pl ${install_prefix}/genf90/bin/genf90.pl
    LOG_DOWNLOAD ON
    LOG_INSTALL ON
)

##
## cmake_fortran_utils
##
ExternalProject_Add(cmake_fortran_utils
    URL ${downloads_prefix}/cmake_fortran_utils.tar.gz
    URL_HASH MD5=a3c39f002a7a81882b65b7eb8c9a7d91
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR> ${install_prefix}/cmake_fortran_utils
    LOG_DOWNLOAD ON
    LOG_INSTALL ON
)

##
## pnetcdf
##
ExternalProject_Add(pnetcdf
    URL ${downloads_prefix}/pnetcdf.tar.gz
    URL_HASH MD5=bb4552a07eadb6c5a54677f96282489d
    BUILD_IN_SOURCE ON
    PATCH_COMMAND patch -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/patches/pnetcdf-1.14.0_gcc15.patch
          COMMAND autoreconf -i
    CONFIGURE_COMMAND env "MPICC=${MPI_C_COMPILER}"
                      env "MPICXX=${MPI_CXX_COMPILER}"
                      env "MPIF90=${MPI_Fortran_COMPILER}"
                      env "MPIF77=${MPI_Fortran_COMPILER}"
                      ./configure --prefix=${install_prefix}/pnetcdf
                                  --disable-shared
                                  --enable-static
    LOG_DOWNLOAD ON
    LOG_CONFIGURE ON
    LOG_BUILD ON
    LOG_INSTALL ON
)

##
## PIO
##
ExternalProject_Add(pio
    URL ${downloads_prefix}/pio.tar.gz
    URL_HASH MD5=b16e88125fbb7e5bd06e8f392f91ae26
    BUILD_IN_SOURCE OFF
    CMAKE_ARGS -DCMAKE_POLICY_VERSION_MINIMUM=3.5
               -DCMAKE_INSTALL_PREFIX=${install_prefix}/pio
               -DCMAKE_C_COMPILER=${MPI_C_COMPILER}
               -DCMAKE_Fortran_COMPILER=${MPI_Fortran_COMPILER}
               -DPIO_ENABLE_TIMING=OFF
               -DPIO_ENABLE_DOC=OFF
               -DPIO_ENABLE_EXAMPLES=OFF
               -DUSER_CMAKE_MODULE_PATH=${install_prefix}/cmake_fortran_utils
               -DGENF90_PATH=${install_prefix}/genf90/bin
               -DNetCDF_PATH=${install_prefix}/netcdf
               -DPnetCDF_PATH=${install_prefix}/pnetcdf
               -DHDF5_PATH=${install_prefix}/hdf5
               -DLIBZ_PATH=${install_prefix}/zlib
    LOG_DOWNLOAD ON
    LOG_CONFIGURE ON
    LOG_BUILD ON
    LOG_INSTALL ON
)
ExternalProject_Add_StepDependencies(pio build netcdf_fortran pnetcdf genf90 cmake_fortran_utils)
