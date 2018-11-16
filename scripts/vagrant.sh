#!/bin/bash
set -euxo pipefail;

# set a default HOME_DIR environment variable if not set
HOME_DIR="${HOME_DIR:-/home/vagrant}";

pubkey_url="https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub";
mkdir -p $HOME_DIR/.ssh;
if command -v wget >/dev/null 2>&1; then
  wget --no-check-certificate "$pubkey_url" -O $HOME_DIR/.ssh/authorized_keys;
else
  echo "Cannot download vagrant public key";
  exit 1;
fi
chown -R vagrant $HOME_DIR/.ssh;
chmod -R go-rwsx $HOME_DIR/.ssh;
