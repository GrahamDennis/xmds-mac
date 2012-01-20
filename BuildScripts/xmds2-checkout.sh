#!/bin/bash

# REVISION=r2478
REVISION=HEAD
REPOSITORY=https://xmds.svn.sourceforge.net/svnroot/xmds/trunk/xpdeint

cd build;
if [ ! -d xmds2 ]; then
    mkdir xmds2
    cd xmds2
    /usr/bin/svn checkout -r $REVISION $REPOSITORY .
else
    cd xmds2
    /usr/bin/svn update -r $REVISION
fi

# Build the documentation
cd admin/userdoc-source;
mkdir -p _static/MathJax
cp -r ../../../../../Vendor/MathJax/{*.js,config,extensions,jax,fonts} _static/MathJax
cp ../../../../mathjax-xmds.js _static/MathJax/config
rm -rf _static/MathJax/fonts/HTML-CSS/*/{png,svg}
rm -rf _static/MathJax/jax/output/HTML-CSS/fonts/STIX
rm -rf _static/MathJax/jax/input/MathML
rm -rf _static/MathJax/jax/element/mml
make html
cd ../..;
cp -r documentation ../../output/share/xmds/
rm -rf documentation


# Delete the checked out code to reduce size
find . -not -path \*\.svn\* -and -type f -delete
cd ..

tar -cjf ../output/distfiles/xmds2-svn.tar.bz2 xmds2/