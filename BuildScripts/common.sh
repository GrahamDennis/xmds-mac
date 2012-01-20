#!/bin/bash

set -o errexit

export PATH=${PWD}/../../output/bin:/usr/bin:/bin:/usr/sbin:/sbin
export OPAL_PREFIX=${PWD}/../../output

export CC="cc" CXX="c++"

function build {
    make clean || true
    ./configure --prefix=$(PWD)/../../output64 CC="${CC}" CXX="${CXX}" --disable-static $* && make -j4 && make install
    make clean || true
    ./configure --prefix=$(PWD)/../../output32 CC="${CC} -arch i386" CXX="${CXX} -arch i386" --disable-static $* && make -j4 && make install
}

