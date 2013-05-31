#!/bin/bash

# You need libmagic and python-magic installed for this script to work (required by create_universal.py)

set -o errexit

OPENMPI_VERSION=1.6.4
# OpenMPI 1.6.1 and later switched to a default pairwise exchange algorithm for MPI_Alltoallv.
# This causes a hang on the mpi_dft_small testcase where one or more MPI processes have no data.
# A reduced testcase needs to be constructed, and needs to be reported to OpenMPI.
FFTW_VERSION=3.3.3
HDF5_VERSION=1.8.11
GSL_VERSION=1.15

VIRTUALENV_VERSION=1.9.1

if [ ! -d source ]; then
	mkdir source/
fi

cd source/

echo "Downloading source packages..."

set +e

curl --remote-name --continue-at - --silent --location http://www.open-mpi.org/software/ompi/v${OPENMPI_VERSION:0:3}/downloads/openmpi-${OPENMPI_VERSION}.tar.bz2
curl --remote-name --continue-at - --silent --location http://fftw.org/fftw-${FFTW_VERSION}.tar.gz
curl --remote-name --continue-at - --silent --location http://www.hdfgroup.org/ftp/HDF5/current/src/hdf5-${HDF5_VERSION}.tar.bz2
curl --remote-name --continue-at - --silent --location http://mirror.aarnet.edu.au/pub/gnu/gsl/gsl-${GSL_VERSION}.tar.gz
curl --remote-name --continue-at - --silent --location http://pypi.python.org/packages/source/v/virtualenv/virtualenv-${VIRTUALENV_VERSION}.tar.gz

set -e

cd ..;
rm -rf build output output32 output64;
mkdir build;
cd build;

tar -xjf ../source/openmpi-${OPENMPI_VERSION}.tar.bz2
cd openmpi-${OPENMPI_VERSION};
../../openmpi.sh;
cd ../..;

./create_universal.py;

cd build;
tar -xzf ../source/fftw-${FFTW_VERSION}.tar.gz
cd fftw-${FFTW_VERSION};
../../fftw.sh;
cd ..;

tar -xjf ../source/hdf5-${HDF5_VERSION}.tar.bz2
cd hdf5-${HDF5_VERSION};
../../hdf5.sh;
cd ..;

tar -xzf ../source/gsl-${GSL_VERSION}.tar.gz
cd gsl-${GSL_VERSION};
../../gsl.sh;
cd ../..;

./create_universal.py

./xmds1.sh;

./create_universal.py

cd build;
mkdir ../output/distfiles;
tar -xzf ../source/virtualenv-${VIRTUALENV_VERSION}.tar.gz
cd virtualenv-${VIRTUALENV_VERSION}
cp virtualenv.py ../../output/share/xmds/
cp virtualenv_support/{distribute-*,pip-*} ../../output/distfiles/
cd ../..

./create_pybundle.sh

./extras.sh

./xmds2-checkout.sh;
