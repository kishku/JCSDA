#!/bin/bash

set -ex

name="eckit"
# source should be either ecmwf or jcsda (fork)
source=$1
version=$2

# build with baselibs?
baselibs=true

# Hyphenated version used for install prefix
compiler=$(echo $COMPILER | sed 's/\//-/g')
mpi=$(echo $MPI | sed 's/\//-/g')

compilerName=$(echo $COMPILER | cut -d/ -f1)

[[ $MAKE_VERBOSE =~ [yYtT] ]] && verb="VERBOSE=1" || unset verb

if $MODULES; then
    set +x
    source $MODULESHOME/init/bash
    if [[ $baselibs ]]; then 
       [[ compilerName = "gnu" ]] && \
          echo yes $compilerName || \
          echo no $compilerName
       [[ compilerName = "gnu" ]] && \
          module load apps/jedi/gcc-7.3_openmpi-3.0.0-baselibs || \
          module load apps/jedi/intel-17.0.7.259-baselibs
       prefix="${PREFIX:-"/opt/modules"}/$compiler/$mpi/$name/$source-$version-baselibs"
    else
       module load core/jedi-$COMPILER
       module load jedi-$MPI
       module load zlib udunits
       module load pnetcdf/1.11.2
       module load netcdf/4.7.0
       module load core/boost-headers core/eigen
       module load core/ecbuild/jcsda-bugfix-old-linker
       prefix="${PREFIX:-"/opt/modules"}/$compiler/$mpi/$name/$source-$version"
    fi
    module load other/cmake
    set -x

    module list

    if [[ -d $prefix ]]; then
	[[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix ) \
                                   || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
    fi

else
    prefix=${ECKIT_ROOT:-"/usr/local"}
fi

export FC=$MPI_FC
export CC=$MPI_CC
export CXX=$MPI_CXX
export F9X=$FC

software=$name
cd ${JEDI_STACK_ROOT}/${PKGDIR:-"pkg"}
[[ -d $software ]] || git clone https://github.com/$source/$software.git
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
git checkout $version
sed -i -e 's/project( eckit CXX/project( eckit CXX Fortran/' CMakeLists.txt
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

ecbuild -DCMAKE_INSTALL_PREFIX=$prefix --build=Release ..
make $verb -j${NTHREADS:-4}
$SUDO make install

# generate modulefile from template
#$MODULES && update_modules mpi $name $source-$version \
#	 || echo $name $source-$version >> ${JEDI_STACK_ROOT}/jedi-stack-contents.log

exit 0
