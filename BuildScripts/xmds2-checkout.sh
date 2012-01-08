#!/bin/bash

rm -rf xmds2
mkdir xmds2
cd xmds2

REVISION=r2476

/usr/bin/svn checkout -r $REVISION https://xmds.svn.sourceforge.net/svnroot/xmds/trunk/xpdeint .

# Delete the checked out code to reduce size
find . -not -path \*\.svn\* -and -type f -delete
cd ..

tar -cjf output/xmds2-svn.tar.bz2 xmds2/