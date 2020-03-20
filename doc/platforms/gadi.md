# Building the JEDI software stack for NCI

To build and install JEDI software stack on Gadi I followed the README.md that is on https://github.com/JCSDA/jedi-stack closely.

## Step 1: Set up Basic Environment

1. Most of the software packages mentioned in README.md are already available on Gadi,
   * Some are available from /bin (e.g. wget, curl); others are available through modulefiles
   * I updated my `.bash_profile` to load those which are available natively
   * Note `setup_environment.sh` is only for a Linux machine with a bare minimum software stack and where you have the root privilege; so for Gadi this script was not used
   * I used Python3 as recommended by Mark Miesch
   * the modulefile for MKL sets up environments for ScaLAPACK, LAPACK and BLAS
   * git-flow is not needed to build jedi-stack
   * Doxygen is available from /bin; I asked Wenming to install Graphviz under ~access
   * only gdb (GNU debugger) is available on Gadi; others - kdbg and valgrind - are not; Yash advises we don't need them but there might be problems later (?)
   * I'm using parallel versions of HDF5 and NETCDF: `hdf5/1.10.5p` and `netcdf/4.7.1p`

2. Since I do not have root privilege I am installing modulefiles on `/g/data/dp9/jtl548/opt/modules`
   * I put `export OPT=/g/data/dp9/jtl548/opt/modules` in my .bash_profile

## Step 2: Configure Build

1. Initially using GNU compiler and Intel MPI: for this I created a new configuration file, `buildscripts/config/config_nci_gnu8.2.1-openmpi3.1.4.sh`.

## Step 3: Set Up Compiler, MPI, and Module System

`setup_modules.sh` copies basic modulefiles which only depend on compiler and MPI (?). Following is a command issued for NCI using Gnu compilers with Open MPI,

```
cd buildscripts
setup_modules.sh nci_gnu8.2.1-openmpi3.1.4
```

Make sure to enter 'Y' when the script asks,
```
WARNING: COMPILER VERSION $COMPILER APPEARS TO BE INCORRECT!
CONTINUE ANYWAY? ANSWER Y OR N
```

## Step 4: Build JEDI Stack

### tcl module management system

Based on the advice of Mark I decided to use `feature/discover` branch. The module management system used on discover is tcl (not Lmod) so this is compatible with our modules.

After running `setup_modules.sh` I have edited relevant `libs/build_*` scripts.

Modulefiles created during the build are loaded by the individual `libs/build_*` scripts and the modulefiles contain lines adding appropriate paths to MODULEPATH (jedi-*????).

### HDF5

I tried to build hdf5 as the NCI-installed hdf5 libraries had unusual names - similar to netddf. However there was problem with shmem and fabric (?). So I decided to use the native hdf5

### NetCDF

* Based on advice from Mark Miesch initially I decided to use the native pnetcdf and netcdf builds rather than building my own pnetcdf and netcdf. However it turned out that NCI did not build its native netcdf (e.g. `netcdf/4.7.1p`) with pnetcdf parallel IO support.
* Then Mark advised me that netcdf with pnetcdf parallel IO support is not needed unless we would be working with older netcdf formats ([his email](/jintaglee/jedi-stack/wiki/EmailFromMarkMiesch_2)). So at this point I decided to use the native netcdf which lacks the pnetnet-enabled parallel IO support
* Subsequently when building ufo-bundle ecbuild failed as it could not find the native netcdf library: the way NCI named the netcdf libraries was unusual and ecbuild's `FindNetCDF4.cmake` failed to find the libraries. To get around this problem I switched on the building of netcdf so that the library is built with the usual names
* When running `make check` to test for the correctness of netcdf build you might see warning messsages like,
  ```
  [gadi-login-01.gadi.nci.org.au:07121] shmem: posix: file name search - max attempts exceeded.cannot continue with posix.
  --------------------------------------------------------------------------
  WARNING: There was an error initializing an OpenFabrics device.
  ```

  This is because `make check` uses MPI launcher - mpirun or mpiexec - to run MPI test jobs on a Gadi login node. You might like to run `make check` manually on a compute node after making sure the compile-time environment is correct set (see `libs/build_netcdf.sh` for compile-time environment)

### Atlas

This package was not built based on the advice from Mark - see [email](/jintaglee/jedi-stack/wiki/EmailFromMarkMiesch_3) from Mark.

### ODC, Odyssesy and Armadillo

Based on advice from Mark Miesch ([his email](/jintaglee/jedi-stack/wiki/EmailFromMarkMiesch)) I decided not to build ODC, Odyssey and Armadillo,
   * if and when I decide to build ODC (JCSDA ODC reporitory is private which means I don't have access to it using my GitHub account) and Odyssey there is a partially completed modulefile for Odyssey (modulefiles_tcl/mpi/gcc/system/openmpi/4.0.2/odyssey/jcsda-develop). See email from Mark Miesch

### PIO

Parallel IO (pio) library was not built as this is only needed in MPAS model bundle

### pyjedi

`libs/build_pyjedi.sh` builds and installs,
  * Various Python2 and Python3 packages under `../.local/lib/python*/site-packages`.
  * py-ncepbufr - used to read NCEP Bufr files

See [email](/jintaglee/jedi-stack/wiki/EmailFromMarkMiesch_3) from Mark.

### ESMF

This package was not built based on the advice from Mark - see [email](/jintaglee/jedi-stack/wiki/EmailFromMarkMiesch_3) from Mark.

### Baselibs

This package was not built based on the advice from Mark - see [email](/jintaglee/jedi-stack/wiki/EmailFromMarkMiesch_3) from Mark.

### Native libraries

Some of the pre-requisite software packages used by JEDI are a little older than what are available on Gadi. The list of versions required by jedi-stack and those which are available on Gadi follows (only those packages which have different versions),

| Software | Version used in jedi-stack | Version available on Gadi | |
| --- | --- | --- | --- |
| cmake | 3.13.0 | 3.16.2 | |
| LAPACK | 3.7.0 | uses Intel MKL and 2020.0.166 not sure what version of LAPACK | |
| boost header and full library | 1.68.0 | 1.71.0 | |
| eigen | 3.3.5 | 3.3.7| |
| nccmp | 1.8.2.1 | 1.8.5.0 | |
| jasper | 1.900.1 | 2.0.16 | |
| xerces | 3.1.4 | 3.2.2 | |
| nco | 4.7.9 | 4.9.2 | |

### Compile-time environment

Before running `build_stack.sh` the top-level jedi modulefile location needs to be prepended to MODULEPATH as well as some modulefiles are loaded to provide tools needed during the build,

```
unset PYTHONPATH                  # when a Python interpreter starts PYTHONPATH is added to sys.path - allow clean module search path
module purge
module use $OPT/modulefiles/core  # The path to the top-level modulefile
module load gcc/system            # GNU compiler
module load openmpi/3.1.4         # or openmpi/4.0.2 - when building nceplibs - e.g. mpif90
module load cmake/3.16.2          # this is to enable the use of later version of CMake which is compatible with bufrlib CMakeLists.txt; **Note.** `libs/build_bufrlib.sh` doesn't have a `module load cmake/<version>` so the module load has to be done outside of the script
module load git/2.24.1            # this newer modulefile allows the use of git-lfs
module load python2/2.7.17        # 2 sets of Python packages are installed: Python2 and Python3
module load python3/3.7.4         # use this version of Python3 unless packages use other Python versions
```

Following is a command issued for NCI using Gnu compilers with Open MPI,

```
cd buildscripts
build_stack.sh nci_gnu8.2.1-openmpi3.1.4.sh > out.txt 2>err.txt &
```

## Remaining Issues

### Changes needing to be made

* In various tcl modulefiles there is a line, `set base /g/data/dp9/jtl548/opt/modules/$comp/$mpi/$name/$ver`; use $OPT to make it easier to handle the building script over to Wenming
* In some limited places of the libs/build_* scripts I had to make small changes. Would it be better to introduce another environment variable to take care of site-specific processing: e.g. `SITE=nci`
* odc is not a public repository and so durng jedi-stack build the script cannot reach odb repo
* `/g/data/dp9/jtl548/opt/modules/gcc-system/openmpi-4.0.2/odyssey/jcsda-develop/lib/python3.7/site-packages` vs `/g/data/dp9/jtl548/opt/modules/gcc-system/openmpi-4.0.2/odb-api/0.18.1.r2/lib/python2.7/site-packages`: why is one built using Python3.7 and another Python2.7?
* When I get around building pio keep following points in mind,
  * libs/build_pio.sh fails as there appears to be problems with using native NetCDF: some environment variables are not available. I may need to build netcdf, hdf5 and pnetcdf
  * also I need to create `modulefiles_tcl/mpi/gcc/system/openmpi/4.0.2/pio/2.4.4`
* Compile-time environment can be set up in `libs/build_*.sh` or directly in the shell in which the build takes place. For portability it's better not to modify the scripts.  
* During the pyjedi build Python2 packages were installed in the right location: `$HOME/.local/lib/python2.7/site-packages`. However during the Python3 build some packages seem to have ended up in the Python2 site-packages directory instead of the directory for Python3. Or it could be that packages are shared between the 2 versions of Python. Ask Milton.
  * there were error messages like,
    ```
    ERROR: matplotlib 2.2.5 requires backports.functools-lru-cache, which is not installed.
    ERROR: matplotlib 2.2.5 requires subprocess32, which is not installed.
    ```
* Do I need to build my own NCO as netcdf is now built?

### Scripts and configurations needing to be rolled back

* In `config/config_nci_gnu8.2.1-openmpi4.0.2.sh` `OVERWRITE` is set to `N` to enable faster build. This should be changed back to `Y`

# Testing jedi-stack

## Build and test ufo-bundle

Source used for test is https://github.com/JCSDA/ufo-bundle develop branch at 25d25ff0

To set up jedi-stack environment,

```
unset PYTHONPATH                                            # when a Python interpreter starts PYTHONPATH is added to sys.path - allow clean module search path
module purge
module use /g/data/dp9/jtl548/opt/modules/modulefiles/core  # prepend this location to MODULEPATH - most jedi-stack modulefiles are
module use /g/data/dp9/jtl548/opt/modules/modulefiles/apps  # prepend this location to MODULEPATH - where top-level modulefile for setting jedi-stack is
module load jedi/gcc-system_openmpi-3.1.4                   # top-level modulefile
```

ecbuild and make succeed. CTest nearly succeeds with 7 failures,

```
99% tests passed, 7 tests failed out of 612

Subproject Time Summary:
fckit    =   2.23 sec*proc (13 tests)
gsw      =   0.27 sec*proc (2 tests)
ioda     =   9.53 sec*proc (14 tests)
oops     =  89.98 sec*proc (256 tests)
saber    = 137.11 sec*proc (106 tests)
ufo      = 266.17 sec*proc (116 tests)

Label Time Summary:
atlas            =  33.94 sec*proc (105 tests)
download_data    =  16.00 sec*proc (4 tests)
executable       = 101.70 sec*proc (182 tests)
fortran          =   5.10 sec*proc (34 tests)
mpi              = 163.55 sec*proc (106 tests)
openmp           = 141.98 sec*proc (106 tests)
script           = 421.54 sec*proc (426 tests)

Total Test time (real) = 541.14 sec

The following tests FAILED:
        140 - test_bump_hdiag-nicas_mask_check_1-1_compare (Failed)
        142 - test_bump_hdiag-nicas_network_1-1_compare (Failed)
        192 - test_bump_hdiag-nicas_mask_check_2-1_compare (Failed)
        194 - test_bump_hdiag-nicas_network_2-1_compare (Failed)
        473 - test_qg_4dvar_saddlepoint_compare (Failed)
        484 - get_ioda_test_data (Failed)
        498 - get_ioda_test_data_ufo (Failed)
```

### Remaining problems

*  Following error message is found,
   ```
   -- Could NOT find FFTW (missing: FFTW_INCLUDE_DIRS FFTW_LIBRARIES double)
   -- Could NOT find package FFTW required for feature FFTW -- Provide FFTW location with -DFFTW_PATH=/...
   -- Feature FFTW was not enabled (also not requested) -- following required packages weren't found: FFTW
   ```
   FFTW3 library is available on Gadi, `fftw3-mkl/2019.3.199` but the modulefile does not seem to export all the necessary environment variables: see `modulefile/mpi/compilerName/compilerVersion/mpiName/mpiVersion/fftw/fftw.lua`

## Build and test fv3-bundle

Source used for test is https://github.com/JCSDA/fv3-bundle develop branch at 2c3d9dff

Same runtime environment as for ufo-bundle.

ecbuild and make succeed. CTest nearly succeeds with 6 failures,

```
99% tests passed, 6 tests failed out of 808

Label Time Summary:
atlas            =  52.75 sec*proc (105 tests)
download_data    = 1325.12 sec*proc (6 tests)
eckit            = 1307.48 sec*proc (114 tests)
executable       = 158.37 sec*proc (285 tests)
fckit            =   2.41 sec*proc (13 tests)
femps            =  13.61 sec*proc (1 test)
fortran          =   6.71 sec*proc (34 tests)
fv3-jedi         = 773.54 sec*proc (86 tests)
fv3jedi          = 777.10 sec*proc (87 tests)
ioda             =  17.72 sec*proc (14 tests)
mpi              = 938.67 sec*proc (171 tests)
oops             = 100.47 sec*proc (256 tests)
openmp           = 138.36 sec*proc (106 tests)
saber            = 145.09 sec*proc (106 tests)
script           = 1337.70 sec*proc (517 tests)
ufo              = 404.57 sec*proc (112 tests)

Total Test time (real) = 2829.83 sec

The following tests FAILED:
        254 - test_bump_hdiag-nicas_mask_check_1-1_compare (Failed)
        256 - test_bump_hdiag-nicas_network_1-1_compare (Failed)
        306 - test_bump_hdiag-nicas_mask_check_2-1_compare (Failed)
        308 - test_bump_hdiag-nicas_network_2-1_compare (Failed)
        587 - test_qg_4dvar_saddlepoint_compare (Failed)
        804 - test_fv3jedi_eda_3dvar_gfs (Failed)
```
