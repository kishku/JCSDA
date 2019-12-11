#!/bin/bash

# These are python tools for use with JEDI

set -ex

name="pyjedi"

[[ $USE_SUDO =~ [yYtT] ]] || ! $MODULES && prefix="/usr/local" \
	                  || prefix="$HOME/.local"

#####################################################################
# Python Package installs
#####################################################################

$SUDO python -m pip install --user -U pip setuptools
$SUDO python -m pip install --user -U numpy
$SUDO python -m pip install --user wheel netCDF4 matplotlib

$SUDO python3 -m pip install --user -U pip setuptools
$SUDO python3 -m pip install --user -U numpy
$SUDO python3 -m pip install --user wheel netCDF4 matplotlib
$SUDO python3 -m pip install --user pycodestyle
$SUDO python3 -m pip install --user autopep8

#####################################################################
# ncepbufr for python
#####################################################################

cd ${JEDI_STACK_ROOT}/${PKGDIR:-"pkg"}
git clone https://github.com/JCSDA/py-ncepbufr.git 
cd py-ncepbufr 

CC=gcc python setup.py build 
$SUDO python setup.py install 

CC=gcc python3 setup.py build 
$SUDO python3 setup.py install 

exit 0
