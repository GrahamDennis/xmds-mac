#!/bin/bash

# REVISION=r2478
REVISION=HEAD
REPOSITORY=https://xmds.svn.sourceforge.net/svnroot/xmds/trunk/xpdeint

if [ ! -d xmds2 ]
    mkdir xmds2
    cd xmds2
    /usr/bin/svn checkout -r $REVISION $REPOSITORY .
else
    cd xmds2
    /usr/bin/svn update -r $REVISION
fi


# Build the documentation
cd admin/userdoc-source;
make html
cd ../..;
cp -r documentation output/share/xmds/
rm -rf documentation


# Delete the checked out code to reduce size
find . -not -path \*\.svn\* -and -type f -delete
cd ..

tar -cjf output/xmds2-svn.tar.bz2 xmds2/