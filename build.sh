#!/bin/bash

ARCH=$1
SERVER=satellite.dictummortuum.com

while (($#)); do
  REPO=$2
  shift
  if [[ -d $REPO ]]; then
    cd $REPO
    rm /tmp/repo/${REPO}*
    sudo -u dimitris makepkg --config ../${ARCH}.conf -fc | tee /tmp/out
    grep "Updated version" /tmp/out
    MSG=$(grep -oP "Updated version: .*" /tmp/out | cut -d ' ' -f3- | sed 's/ / v/')
    [[ -f /tmp/${REPO}.tar.gz ]] && rm /tmp/${REPO}.tar.gz
    ARTIFACT=$(ls /tmp/repo/${REPO}*)
    sudo -u dimitris scp $ARTIFACT ${SERVER}:/tmp
    sudo -u dimitris ssh ${SERVER} "sudo cp /tmp/$(basename ${ARTIFACT}) /mnt/nfsserver/apps/repo/${ARCH}"
    git cm "$MSG"
    cd ..
  fi
done

sudo -u dimitris ssh ${SERVER} "sudo /mnt/nfsserver/apps/repo/${ARCH}/create_repo.sh"
