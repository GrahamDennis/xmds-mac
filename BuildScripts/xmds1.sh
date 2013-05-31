#!/bin/bash

source common.sh;

# autoconf et al are no longer distributed with Xcode. So we need to grab them from macports or homebrew
export PATH=$PATH:/opt/local/bin:/usr/local/bin

rm -rf build/xmds1
mkdir -p build/xmds1
cd build/xmds1

svn checkout http://svn.code.sf.net/p/xmds/code/trunk/xmds-devel .

# xmds1 use an old macro that causes an error, we need to replace it
sed -i '' 's/AM_CONFIG_HEADER/AC_CONFIG_HEADERS/g' configure.in

autoreconf;

function patch_config_header {
	cat source/config.h | sed -e 's/XMDS_INCLUDES ".*"/XMDS_INCLUDES "\\\"-I${XMDS_USR}\/include\\\""/' -e 's/XMDS_CC ".*"/XMDS_CC "c++"/' -e 's/FFTW_LIBS ".*"/FFTW_LIBS "\\\"-L${XMDS_USR}\/lib\\\" -lfftw3"/' -e 's/FFTW3_LIBS ".*"/FFTW3_LIBS "\\\"-L${XMDS_USR}\/lib\\\" -lfftw3"/' > source/config.h.new
	mv source/config.h.new source/config.h
    cp source/config.h xmds_config.h
}

function build {
    make clean || true
    
    ./configure --prefix=$(PWD)/../../output64 CC="${CC}" CXX="${CXX}" --disable-static $*
    patch_config_header
    make -j 4 && make install
	
    make clean || true
    ./configure --prefix=$(PWD)/../../output32 CC="${CC} -arch i386" CXX="${CXX} -arch i386" --disable-static $*
    patch_config_header
    make -j 4 && make install
}

build --with-fftw3-path=`pwd`/../../output --enable-fftw3 --enable-threads --program-suffix=1