#!/bin/bash

rm -rf build/extras
mkdir -p build/extras
cd build/extras

svn export http://svn.code.sf.net/p/xmds/code/trunk/xpdeint/admin/xpdeint.tmbundle xpdeint.tmbundle

cd ..
cp -r extras ../output/share/xmds/