#!/bin/bash

cd build;
pip bundle ../output/xmds2-requirements.pybundle -r ../requirements.txt

rm -rf build-bundle