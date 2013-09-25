#!/bin/bash

set -o errexit

export PATH=${XMDS_BUILD_BASE}/output/bin:/usr/bin:/bin:/usr/sbin:/sbin
export OPAL_PREFIX=${XMDS_BUILD_BASE}/output

export CC="gcc" CXX="g++"

function build {
    make clean || true
    ./configure --prefix=$(PWD)/../../output64 CC="${CC} -mmacosx-version-min=10.5" CXX="${CXX}" --disable-static $* && make -j4 && make install
    make clean || true
    ./configure --prefix=$(PWD)/../../output32 CC="${CC} -mmacosx-version-min=10.5 -arch i386" CXX="${CXX} -arch i386" --disable-static $* && make -j4 && make install
}

