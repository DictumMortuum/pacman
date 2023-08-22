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
  --needed aarch64-linux-gnu-binutils

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

# build the package
ARCH=$1
REPO=$2

echo "$@ , $ARCH , $INPUT_ARCH , $REPO , $INPUT_REPO"

cd $INPUT_REPO
sudo -u pkguser makepkg --config ../${INPUT_ARCH}.conf -fc

# print out the packages for debugging
ls -l /tmp/

chown -R "$og" .
