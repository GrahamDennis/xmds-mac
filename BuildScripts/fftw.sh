#!/bin/bash

source ../../common.sh;

# This is to use our hacked-together clang-3.1 assembler for avx
export PATH=`pwd`/../../:${PATH}

# We have included this function here because we can only use avx with the 64-bit build.
function build {
    export CC="/opt/local/bin/gcc-mp-4.5"
    ./configure --prefix=$(PWD)/../../output64 OMPI_CC="${CC}" MPICC="mpicc" CC="${CC}" --disable-static --enable-avx $* && make -j4 && make install
    make clean
    export CC="cc -arch i386"
    ./configure --prefix=$(PWD)/../../output32 CC="${CC}" OMPI_CC="${CC}" MPICC=`pwd`/../../output32/bin/mpicc --disable-static $* && make -j4 && make install
}


build --enable-sse2 --enable-mpi --disable-fortran --enable-threads
build --enable-sse2 --enable-mpi --disable-fortran --enable-threads --enable-float
