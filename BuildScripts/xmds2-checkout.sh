#!/bin/bash

rm -rf xmds2-checkout
mkdir xmds2-checkout
cd xmds2-checkout

svn checkout https://xmds.svn.sourceforge.net/svnroot/xmds/trunk/xpdeint .

# Delete the checked out code to reduce size
find . -not -path \*\.svn\* -and -type f -delete
cd ..