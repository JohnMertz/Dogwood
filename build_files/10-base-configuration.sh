#!/usr/bin/env bash

set -xeuo pipefail

# Add akmods secureboot key
mkdir -p /etc/pki/akmods/certs
curl --retry 15 -Lo /etc/pki/akmods/certs/akmods-ublue.der "https://github.com/ublue-os/akmods/raw/main/certs/public_key.der"

# This package adds "[systemd] Failed Units: *" to the bashrc startup
dnf -y remove console-login-helper-messages
