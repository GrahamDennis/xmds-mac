#!/bin/bash

rm -rf build/extras
mkdir -p build/extras
cd build/extras

svn export https://xmds.svn.sourceforge.net/svnroot/xmds/trunk/support/XMDS.tmbundle XMDS.tmbundle

cd ..
cp -r extras ../output/share/xmds/