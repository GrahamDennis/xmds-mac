#!/bin/bash

source ../../common.sh;

# This is to use our hacked-together clang-3.1 assembler for avx
# export PATH=`pwd`/../../:${PATH}

# We have included this function here because we can only use avx with the 64-bit build.
function build {
    make clean || true
    export CC="/opt/local/bin/gcc-mp-4.7 -mmacosx-version-min=10.5"
    export OMPI_CC="${CC}"
    # ./configure --prefix=$(PWD)/../../output64 MPICC="mpicc" --enable-avx $* && make -j4 && make install
    ./configure --prefix=$(PWD)/../../output64 MPICC="mpicc" $* && make -j4 && make install
    cp tests/bench ../../output64/bin/fftw_bench_temp
    cp mpi/mpi-bench ../../output64/bin/fftw_mpi_bench_temp
    make clean || true
    export CC="gcc -arch i386 -mmacosx-version-min=10.5"
    export OMPI_CC="${CC}"
    ./configure --prefix=$(PWD)/../../output32 MPICC="mpicc" $* && make -j4 && make install
    cp tests/bench ../../output32/bin/fftw_bench_temp
    cp mpi/mpi-bench ../../output32/bin/fftw_mpi_bench_temp
}


build --enable-sse2 --enable-mpi --disable-fortran --enable-threads
mv ../../output64/bin/fftw_bench_temp     ../../output64/bin/fftw-bench
mv ../../output32/bin/fftw_bench_temp     ../../output32/bin/fftw-bench
mv ../../output64/bin/fftw_mpi_bench_temp ../../output64/bin/fftw-mpi-bench
mv ../../output32/bin/fftw_mpi_bench_temp ../../output32/bin/fftw-mpi-bench

build --enable-sse2 --enable-mpi --disable-fortran --enable-threads --enable-float
mv ../../output64/bin/fftw_bench_temp ../../output64/bin/fftwf-bench
mv ../../output32/bin/fftw_bench_temp ../../output32/bin/fftwf-bench
mv ../../output64/bin/fftw_mpi_bench_temp ../../output64/bin/fftwf-mpi-bench
mv ../../output32/bin/fftw_mpi_bench_temp ../../output32/bin/fftwf-mpi-bench
