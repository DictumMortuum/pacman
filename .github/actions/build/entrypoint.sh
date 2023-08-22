#!/bin/bash

set -ex

# Bootstrap script to be run as root after image is built

# Update packages
pacman-key --init
pacman -Syu --noconfirm \
  --ignore linux \
  --ignore linux-firmware \
  --needed base-devel \
  --needed go \
  --needed aarch64-linux-gnu-binutils \
  --needed openssh

# Ensure wheel group exists (seriously??)
groupadd -f -r wheel

# Create an unprivileged user
useradd -m -G wheel -s /bin/bash pkguser

# Grant group wheel sudo rights without password.
echo "%wheel ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/wheel

# Run pkgbuild script as unprivileged user
og=$(stat -c '%u:%g' .)
chown -R pkguser: .

# print out the limits for debugging
ulimit -Sn
ulimit -Hn

cd $INPUT_REPO
sudo -u pkguser makepkg --config ../${INPUT_ARCH}.conf -fc

# print out the packages for debugging
ls -l /tmp/repo

# create the rsa key for the transfer
echo ${INPUT_UPLOAD_KEY} >> /tmp/id_rsa

# upload artifact and update the repository
[[ -f /tmp/${INPUT_REPO}.tar.gz ]] && rm /tmp/${INPUT_REPO}.tar.gz
ARTIFACT=$(ls /tmp/repo/${INPUT_REPO}*)
scp -o 'StrictHostKeyChecking no' -i /tmp/id_rsa $ARTIFACT ${INPUT_UPLOAD_HOST}:/tmp
ssh -o 'StrictHostKeyChecking no' -i /tmp/id_rsa ${INPUT_UPLOAD_HOST} "sudo cp /tmp/$(basename ${ARTIFACT}) /mnt/nfsserver/apps/repo/${INPUT_ARCH}"
ssh -o 'StrictHostKeyChecking no' -i /tmp/id_rsa ${INPUT_UPLOAD_HOST} "sudo /mnt/nfsserver/apps/repo/${INPUT_ARCH}/create_repo.sh"

chown -R "$og" .
