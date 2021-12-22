#!/bin/bash

REPO=$1
ARCH=$2

if [[ -d $REPO ]]; then
  cd $REPO
  sudo -u dimitris makepkg --config ../${ARCH}.conf -fc
  [[ -f /tmp/${REPO}.tar.gz ]] && rm /tmp/${REPO}.tar.gz
  cd ..
fi
