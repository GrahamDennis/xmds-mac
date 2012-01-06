#!/bin/bash

source common.sh;

rm -rf build/xmds1
mkdir -p build/xmds1
cd build/xmds1

svn checkout https://xmds.svn.sourceforge.net/svnroot/xmds/trunk/xmds-devel .

autoreconf;

build --with-fftw3-path=`pwd`/../../output --enable-fftw3 --enable-threads --program-suffix=1