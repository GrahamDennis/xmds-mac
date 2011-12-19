#!/bin/bash

export PATH=${PWD}/../../output/bin:/usr/bin:/bin:/usr/sbin:/sbin
export OPAL_PREFIX=${PWD}/../../output

function build {
    export CC="/opt/local/bin/gcc-mp-4.5" CXX="/opt/local/bin/g++-mp-4.5"
    ./configure --prefix=$(PWD)/../../output64 CC="${CC}" CXX="${CXX}" --disable-static $* && make -j4 && make install
    make clean
    export CC="cc" CXX="c++"
    ./configure --prefix=$(PWD)/../../output32 CC="${CC} -arch i386" CXX="${CXX} -arch i386" --disable-static $* && make -j4 && make install
}

