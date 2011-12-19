#!/bin/bash

source ../../common.sh;

build --enable-sse2 --enable-mpi --disable-fortran --enable-threads
build --enable-sse2 --enable-mpi --disable-fortran --enable-threads --enable-float
