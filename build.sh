#!/bin/bash

for i in $*; do
  if [[ -d $i ]]; then
    cd $i
    makepkg --config ../aarch64.conf -fc
    rm /tmp/${i}.tar.gz
    #makepkg --config ../aarch64.conf -fc
    cd ..
  fi
done
