#!/bin/bash

# These are python tools for use with JEDI

set -ex

name="pyjedi"

[[ $USE_SUDO =~ [yYtT] ]] || ! $MODULES && prefix=${PYJEDI_ROOT:-"/usr/local"} \
	                  || prefix="$HOME/.local"

[[ $USE_SUDO =~ [yYtT] ]] || $MODULES && unset LOCALPY || LOCALPY="--user"

#####################################################################
# Python Package installs
#####################################################################

$SUDO python3 -m pip install $LOCALPY -U pip setuptools
$SUDO python3 -m pip install $LOCALPY -U numpy
$SUDO python3 -m pip install $LOCALPY -U wheel netCDF4 matplotlib
$SUDO python3 -m pip install $LOCALPY -U pandas
$SUDO python3 -m pip install $LOCALPY -U pycodestyle
$SUDO python3 -m pip install $LOCALPY -U autopep8
$SUDO python3 -m pip install $LOCALPY -U cffi
$SUDO python3 -m pip install $LOCALPY -U pycparser
$SUDO python3 -m pip install $LOCALPY -U pytest

#####################################################################
# ncepbufr for python
#####################################################################

cd ${JEDI_STACK_ROOT}/${PKGDIR:-"pkg"}
git clone https://github.com/JCSDA/py-ncepbufr.git 
cd py-ncepbufr 

CC=gcc python3 setup.py build 
$SUDO python3 setup.py install 

exit 0
