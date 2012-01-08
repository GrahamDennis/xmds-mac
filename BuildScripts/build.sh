#!/bin/bash

OPENMPI_VERSION=1.4.4
FFTW_VERSION=3.3
HDF5_VERSION=1.8.8
GSL_VERSION=1.15

mkdir source/
cd source/

echo "Downloading source packages..."

curl -O -C - -s http://www.open-mpi.org/software/ompi/v${OPENMPI_VERSION:0:3}/downloads/openmpi-${OPENMPI_VERSION}.tar.bz2
curl -O -C - -s http://fftw.org/fftw-${FFTW_VERSION}.tar.gz
curl -O -C - -s http://www.hdfgroup.org/ftp/HDF5/current/src/hdf5-${HDF5_VERSION}.tar.bz2
curl -O -C - -s http://mirror.aarnet.edu.au/pub/gnu/gsl/gsl-${GSL_VERSION}.tar.gz

cd ..;
rm -rf build output32 output64;
mkdir build;
cd build;

tar -xzf ../source/openmpi-${OPENMPI_VERSION}.tar.bz2
cd openmpi-${OPENMPI_VERSION};
../../openmpi.sh;
cd ../..;

./create_universal.py;

cd build;
tar -xzf ../source/fftw-${FFTW_VERSION}.tar.gz
cd fftw-${FFTW_VERSION};
../../fftw.sh;
cd ..;

tar -xzf ../source/hdf5-${HDF5_VERSION}.tar.bz2
cd hdf5-${HDF5_VERSION};
../../hdf5.sh;
cd ..;

tar -xzf ../source/gsl-${GSL_VERSION}.tar.gz
cd gsl-${GSL_VERSION};
../../gsl.sh;
cd ../..;

./create_universal.py

./xmds1.sh;

./create_pybundle.sh

./xmds2-checkout.sh;

./create_universal.py
