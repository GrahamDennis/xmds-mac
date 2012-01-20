#!/bin/bash

source common.sh;

rm -rf build/xmds1
mkdir -p build/xmds1
cd build/xmds1

svn checkout https://xmds.svn.sourceforge.net/svnroot/xmds/trunk/xmds-devel .

autoreconf;

function patch_config_header {
	cat source/config.h | sed -e 's/XMDS_INCLUDES ".*"/XMDS_INCLUDES "\\\"-I${XMDS_USR}\/include\\\""/' -e 's/XMDS_CC ".*"/XMDS_CC "g++"/' -e 's/FFTW_LIBS ".*"/FFTW_LIBS "\\\"-L${XMDS_USR}\/lib\\\" -lfftw3"/' -e 's/FFTW3_LIBS ".*"/FFTW3_LIBS "\\\"-L${XMDS_USR}\/lib\\\" -lfftw3"/' > source/config.h.new
	mv source/config.h.new source/config.h
    cp source/config.h xmds_config.h
}

function build {
    export CC="/opt/local/bin/gcc-mp-4.5" CXX="/opt/local/bin/g++-mp-4.5"
    make clean || true
    
    ./configure --prefix=$(PWD)/../../output64 CC="${CC}" CXX="${CXX}" --disable-static $*
    patch_config_header
    make -j4 && make install
    
    make clean || true
    export CC="cc" CXX="c++"
    ./configure --prefix=$(PWD)/../../output32 CC="${CC} -arch i386" CXX="${CXX} -arch i386" --disable-static $*
    patch_config_header
    make -j4 && make install
}

build --with-fftw3-path=`pwd`/../../output --enable-fftw3 --enable-threads --program-suffix=1