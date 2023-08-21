#!/bin/bash

ARCH=$1
REPO=$2
cd $REPO
echo "time=$REPO" >> $GITHUB_OUTPUT
makepkg --config ../${ARCH}.conf -fc
ls -l
echo "time=$REPO" >> $GITHUB_OUTPUT
