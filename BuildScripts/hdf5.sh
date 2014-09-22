#!/bin/bash

source generic.sh

sed 's/^prefix=".*"$/prefix="${XMDS_USR}"/' $(PWD)/../../output32/bin/h5cc > $(PWD)/../../output32/bin/h5cc.new
mv $(PWD)/../../output32/bin/h5cc.new $(PWD)/../../output32/bin/h5cc
sed 's/^prefix=".*"$/prefix="${XMDS_USR}"/' $(PWD)/../../output64/bin/h5cc > $(PWD)/../../output64/bin/h5cc.new
mv $(PWD)/../../output64/bin/h5cc.new $(PWD)/../../output64/bin/h5cc
