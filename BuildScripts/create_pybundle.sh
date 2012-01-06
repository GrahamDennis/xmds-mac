#!/bin/bash

cd build;
pip bundle ../output_noarch/xmds2_requirements.pybundle -r requirements.txt

rm -rf build-bundle