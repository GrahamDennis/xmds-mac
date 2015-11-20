#!/bin/bash

set -o errexit

cd build;
pip install --no-binary :all: --download ../output/distfiles -r ../output_noarch/share/xmds/requirements.txt

rm -rf build-bundle