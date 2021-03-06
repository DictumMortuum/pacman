#!/bin/bash

REPO=$1
ARCH=$2

if [[ -d $REPO ]]; then
  cd $REPO
  rm /tmp/repo/${REPO}*
  sudo -u dimitris makepkg --config ../${ARCH}.conf -fc | tee /tmp/out
  grep "Updated version" /tmp/out
  MSG=$(grep -oP "Updated version: .*" /tmp/out | cut -d ' ' -f3- | cut -d '-' -f1 | sed 's/ / v/')
  [[ -f /tmp/${REPO}.tar.gz ]] && rm /tmp/${REPO}.tar.gz
  ARTIFACT=$(ls /tmp/repo/${REPO}*)
  sudo -u dimitris scp $ARTIFACT satellite:/tmp
  sudo -u dimitris ssh satellite "sudo cp /tmp/$(basename ${ARTIFACT}) /mnt/nfsserver/apps/repo/${ARCH}"
  sudo -u dimitris ssh satellite "sudo /mnt/nfsserver/apps/repo/${ARCH}/create_repo.sh"
  git cm "$MSG"
  cd ..
fi
