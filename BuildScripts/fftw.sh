#!/bin/bash

source ../../common.sh;

# This is to use our hacked-together clang-3.1 assembler for avx
export PATH=`pwd`/../../:${PATH}

# We have included this function here because we can only use avx with the 64-bit build.
function build {
    make clean || true
    export CC="/opt/local/bin/gcc-mp-4.5"
    export OMPI_CC="${CC}"
    ./configure --prefix=$(PWD)/../../output64 MPICC="mpicc" --disable-static --enable-avx $* && make -j4 && make install
    cp tests/bench ../../output64/bin/fftw_bench_temp
    make clean || true
    export CC="cc -arch i386"
    export OMPI_CC="${CC}"
    ./configure --prefix=$(PWD)/../../output32 MPICC=mpicc --disable-static $* && make -j4 && make install
    cp tests/bench ../../output32/bin/fftw_bench_temp
}


build --enable-sse2 --enable-mpi --disable-fortran --enable-threads
mv ../../output64/bin/fftw_bench_temp ../../output64/bin/fftw-bench
mv ../../output32/bin/fftw_bench_temp ../../output32/bin/fftw-bench

build --enable-sse2 --enable-mpi --disable-fortran --enable-threads --enable-float
mv ../../output64/bin/fftw_bench_temp ../../output64/bin/fftwf-bench
mv ../../output32/bin/fftw_bench_temp ../../output32/bin/fftwf-bench
