#!/bin/bash

python virtualenv.py --no-site-packages output

ln -s /System/Library/Frameworks/Python.framework/Versions/2.7/Extras/lib/python/numpy output/lib/python2.7/site-packages/numpy

export PATH=${PWD}/output/bin:/usr/bin:/bin:/usr/sbin:/sbin
export HDF5_DIR=${PWD}/output
pip install lxml pygments Sphinx mpmath h5py Cheetah pyparsing