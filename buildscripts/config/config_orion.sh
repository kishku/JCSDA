#!/bin/bash

# Compiler/MPI combination
export JEDI_COMPILER="intel/2019.5"
export JEDI_MPI="openmpi/4.0.2"

# This tells jedi-stack how you want to build the compiler and mpi modules
# valid options include:
# native-module: load a pre-existing module (common for HPC systems)
# native-pkg: use pre-installed executables located in /usr/bin or /usr/local/bin,
#             as installed by package managers like apt-get or hombrewo.
#             This is a common option for, e.g., gcc/g++/gfortrant
# from-source: This is to build from source
export JEDI_COMPILER_BUILD="native-module"
export MPI_BUILD="native-module"

# Build options
export PREFIX=${HOME}/opt
export USE_SUDO=N
export PKGDIR=pkg
export LOGDIR=buildscripts/log
export OVERWRITE=Y
export NTHREADS=8
export   MAKE_CHECK=N
export MAKE_VERBOSE=N
export   MAKE_CLEAN=N
export DOWNLOAD_ONLY=F
export STACK_EXIT_ON_FAIL=T
export WGET="wget -nv"

# Minimal JEDI Stack
export      STACK_BUILD_CMAKE=Y
export       STACK_BUILD_SZIP=Y
export    STACK_BUILD_UDUNITS=Y
export       STACK_BUILD_ZLIB=Y
export     STACK_BUILD_LAPACK=Y
export STACK_BUILD_BOOST_HDRS=Y
export     STACK_BUILD_EIGEN3=Y
export       STACK_BUILD_HDF5=Y
export    STACK_BUILD_PNETCDF=Y
export     STACK_BUILD_NETCDF=Y
export      STACK_BUILD_NCCMP=Y
export        STACK_BUILD_NCO=Y
export    STACK_BUILD_ECBUILD=N
export      STACK_BUILD_ECKIT=N
export      STACK_BUILD_FCKIT=N
export        STACK_BUILD_ODB=N
export        STACK_BUILD_ODC=N
export    STACK_BUILD_ODYSSEY=N
export    STACK_BUILD_BUFRLIB=N

# Optional Additions
export           STACK_BUILD_PIO=N
export        STACK_BUILD_PYJEDI=N
export      STACK_BUILD_NCEPLIBS=N
export          STACK_BUILD_JPEG=N
export           STACK_BUILD_PNG=N
export        STACK_BUILD_JASPER=N
export     STACK_BUILD_ARMADILLO=N
export        STACK_BUILD_XERCES=N
export        STACK_BUILD_TKDIFF=N
export    STACK_BUILD_BOOST_FULL=N
export          STACK_BUILD_ESMF=N
export      STACK_BUILD_BASELIBS=N
export     STACK_BUILD_PDTOOLKIT=N
export          STACK_BUILD_TAU2=N
export          STACK_BUILD_CGAL=N

