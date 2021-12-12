#!/bin/bash

for i in *; do
  if [[ -d $i ]]; then
    cd $i
    makepkg --config ../x86_64.conf -fc
    makepkg --config ../aarch64.conf -fc
    cd ..
  fi
done
