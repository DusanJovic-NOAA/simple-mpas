## Standalone MPAS-Model build 'driver'
cmake_minimum_required(VERSION 3.12)

project(standalone_mpas_build)


list(APPEND CMAKE_MODULE_PATH $ENV{ESMF_ROOT}/cmake)
list(APPEND CMAKE_MODULE_PATH $ENV{esmf_ROOT}/cmake)

set(USE_ESMF_STATIC_LIBS ON)
find_package(ESMF 8.8.0 MODULE REQUIRED)

add_subdirectory(MPAS-Model)
