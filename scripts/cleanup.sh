#!/bin/bash
set -Eeux;

# Delete all Linux headers
PKGS_LINUX_HEADERS=( $(dpkg --list | awk '{ print $2 }' | grep 'linux-headers' || true) );

# Remove specific Linux kernels, such as linux-image-3.11.0-15-generic but
# keeps the current kernel and does not touch the virtual packages,
# e.g. 'linux-image-generic', etc.
PKGS_LINUX_IMAGE=( $(dpkg --list | awk '{ print $2 }' | grep 'linux-image-.*-generic' | grep -v `uname -r` || true) );

# Delete Linux source
PKGS_LINUX_SOURCE=( $(dpkg --list | awk '{ print $2 }' | grep 'linux-source' || true) );

# Delete development packages
PKGS_DEV=( $(dpkg --list | awk '{ print $2 }' | grep -- '-dev$' || true) );

# delete docs packages
PKGS_DOC=( $(dpkg --list | awk '{ print $2 }' | grep -- '-doc$' || true) );

# Delete X11 libraries
PKGS_X11=( \
  libx11-data \
  xauth \
  libxmuu1 \
  libxcb1 \
  libx11-6 \
  libxext6 \
  libxau6 \
);

# Delete obsolete networking
PKGS_OBSOLETE_NETWORKING=( \
  ppp \
  pppconfig \
  pppoeconf \
);

# Delete oddities
PKGS_ODDITIES=( \
  popularity-contest \
  installation-report \
  command-not-found \
  command-not-found-data \
  friendly-recovery \
  bash-completion \
  fonts-ubuntu-font-family-console \
  laptop-detect \
);

# Delete some packages
PKGS_OTHER=( \
  usbutils \
  libusb-1.0-0 \
  binutils \
  console-setup \
  console-setup-linux \
  cpp \
  cpp-5 \
  crda \
  iw \
  wireless-regdb \
  eject \
  file \
  keyboard-configuration \
  krb5-locales \
  libmagic1 \
  make \
  manpages \
  netcat-openbsd \
  os-prober \
  tasksel \
  tasksel-data \
  vim-common \
  whiptail \
  xkb-data \
  pciutils \
  ubuntu-advantage-tools \
  tcpd \
);

PKGS=( \
  "${PKGS_LINUX_HEADERS[@]:+${PKGS_LINUX_HEADERS[@]}}" \
  "${PKGS_LINUX_IMAGE[@]:+${PKGS_LINUX_IMAGE[@]}}" \
  "${PKGS_LINUX_SOURCE[@]:+${PKGS_LINUX_SOURCE[@]}}" \
  "${PKGS_DEV[@]:+${PKGS_DEV[@]}}" \
  "${PKGS_DOC[@]:+${PKGS_DOC[@]}}" \
  "${PKGS_X11[@]}" \
  "${PKGS_OBSOLETE_NETWORKING[@]}" \
  "${PKGS_ODDITIES[@]}" \
  "${PKGS_OTHER[@]}" \
);

apt-get -y purge "${PKGS[@]}";

# Exlude the files we don't need w/o uninstalling linux-firmware
echo "==> Setup dpkg excludes for linux-firmware"
cat <<_EOF_ | cat >> /etc/dpkg/dpkg.cfg.d/excludes
#PACKER-BEGIN
path-exclude=/lib/firmware/*
path-exclude=/usr/share/doc/linux-firmware/*
#PACKER-END
_EOF_

# Delete the massive firmware packages
rm -rf /lib/firmware/*
rm -rf /usr/share/doc/linux-firmware/*

apt-get -y autoremove;
apt-get -y clean;

# Remove docs
rm -rf /usr/share/doc/*

# Remove caches
find /var/cache -type f -exec rm -rf {} \;

# delete any logs that have built up during the install
find /var/log/ -name *.log -exec rm -f {} \;

# Blank netplan machine-id (DUID) so machines get unique ID generated on boot.
truncate -s 0 /etc/machine-id

