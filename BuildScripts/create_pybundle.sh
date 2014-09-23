#!/bin/bash

set -o errexit

cd build;
pip bundle --no-use-wheel ../output/distfiles/xmds2-requirements.pybundle -r ../requirements.txt

rm -rf build-bundle