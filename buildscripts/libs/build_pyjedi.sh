#!/bin/bash

# These are python tools for use with JEDI

set -ex

name="pyjedi"

[[ $USE_SUDO =~ [yYtT] ]] || ! $MODULES && prefix=${PYJEDI_ROOT:-"/usr/local"} \
	                  || prefix="$HOME/.local"

#####################################################################
# Python Package installs
#####################################################################

# force the use of Python2 before installing Python2 packages
module unload python2 python3
module load python2/2.7.17

$SUDO python -m pip install -U pip setuptools
$SUDO python -m pip install -U numpy
$SUDO python -m pip install -U wheel netCDF4 matplotlib

# force the use of Python3 before installing Python3 packages
module unload python2 python3
module load python3/3.7.4

# NCI
# Python3 pip does not seem to automatically install packages under user's .local/
# so "--user" is added
$SUDO python3 -m pip install -U --user pip setuptools
$SUDO python3 -m pip install -U --user numpy
$SUDO python3 -m pip install -U --user wheel netCDF4 matplotlib
$SUDO python3 -m pip install -U --user pandas
$SUDO python3 -m pip install -U --user pycodestyle
$SUDO python3 -m pip install -U --user autopep8
$SUDO python3 -m pip install -U --user cffi
$SUDO python3 -m pip install -U --user pycparser
$SUDO python3 -m pip install -U --user pytest

#####################################################################
# ncepbufr for python
#####################################################################

cd ${JEDI_STACK_ROOT}/${PKGDIR:-"pkg"}
git clone https://github.com/JCSDA/py-ncepbufr.git 
cd py-ncepbufr 

# force the use of Python2 before installing Python2 packages
module unload python2 python3
module load python2/2.7.17

CC=gcc python setup.py build 
if [[ $USE_SUDO =~ [yYtT] ]]
then
    $SUDO python setup.py install
else
    python setup.py install --user
fi

# force the use of Python3 before installing Python3 packages
module unload python2 python3
module load python3/3.7.4

# Python module search path seems to have "$HOME/.local/lib/python2.7" first and
# so during the command, "python3 setup.py build" Python2 modules are picked up
# first. To prevent this and to force the command to use Python3 following is
# added
export PYTHONPATH=${HOME}/.local/lib/python3.7/site-packages

CC=gcc python3 setup.py build 
if [[ $USE_SUDO =~ [yYtT] ]]
then
    $SUDO python3 setup.py install
else
    python3 setup.py install --user
fi

exit 0
