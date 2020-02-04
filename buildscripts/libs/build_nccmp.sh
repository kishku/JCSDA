#!/bin/bash

set -ex

name="nccmp"
version=$1

# build with baselibs?
baselibs=true

software=$name-$version

# Hyphenated version used for install prefix
compiler=$(echo $COMPILER | sed 's/\//-/g')
mpi=$(echo $MPI | sed 's/\//-/g')

if $MODULES; then
    set +x
    source $MODULESHOME/init/bash
    if [[ $baselibs ]]; then
       [[ compilerName = "gnu" ]] && \
          module load apps/jedi/gcc-7.3_openmpi-3.0.0-baselibs || \
          module load apps/jedi/intel-17.0.7.259-baselibs
       prefix="${PREFIX:-"/opt/modules"}/$compiler/$mpi/$name/$version-baselibs"
    else
       module load core/jedi-$COMPILER
       module load jedi-$MPI
       module load zlib udunits
       module load hdf5
       module load pnetcdf/1.11.2
       module load netcdf/4.7.0
       module load core/boost-headers core/eigen
       module load core/ecbuild/jcsda-bugfix-old-linker
       prefix="${PREFIX:-"/opt/modules"}/$compiler/$mpi/$name/$version"
    fi
    module load other/cmake
    module list
    set -x

    if [[ -d $prefix ]]; then
	[[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix ) \
                                   || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
    fi
else
    prefix=${NCCMP_ROOT:-"/usr/local"}
fi

export FC=$MPI_FC
export CC=$MPI_CC
export CXX=$MPI_CXX

export CFLAGS="-fPIC"
export LDFLAGS="-L$NETCDF_ROOT/lib -L$HDF5_ROOT/lib -L$SZIP_ROOT/lib"

url="https://sourceforge.net/projects/nccmp/files/${software}.tar.gz"

cd ${JEDI_STACK_ROOT}/${PKGDIR:-"pkg"}

# Enable header pad comparison, if netcdf-c src directory exists!
[[ -d "netcdf-c-$NETCDF_VERSION" ]] && extra_confs="--with-netcdf=$PWD/netcdf-c-$NETCDF_VERSION" || extra_confs=""

[[ -d $software ]] || ( $WGET $url; tar -xf $software.tar.gz )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

../configure --prefix=$prefix $extra_confs

make -j${NTHREADS:-4}
[[ $MAKE_CHECK =~ [yYtT] ]] && make check
$SUDO make install

# generate modulefile from template
#$MODULES && update_modules mpi $name $version \
#	 || echo $name $version >> ${JEDI_STACK_ROOT}/jedi-stack-contents.log			   

exit 0
