#!/bin/bash

export PATH=${PWD}/../../output/bin:/usr/bin:/bin:/usr/sbin:/sbin

./configure --prefix=$(PWD)/../../output --disable-static
make -j4 ;
make install
