#!/bin/bash

export PATH=${PWD}/../../output/bin:/usr/bin:/bin:/usr/sbin:/sbin

function build {
	./configure --prefix=${PWD}/../../output $1 --enable-sse2 --enable-mpi --disable-fortran --enable-threads
	make -j4 install;
}

build "--enable-float";
build;

