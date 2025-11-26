#!/bin/bash

set -xeuo pipefail

# This is a bucket list. We want to not have anything in this file at all.

# Enable the same compose repos during our build that the centos-bootc image
# uses during its build.  This avoids downgrading packages in the image that
# have strict NVR requirements.
#curl --retry 3 -Lo "/etc/yum.repos.d/fedora-coreos.repo" "https://raw.githubusercontent.com/coreos/fedora-coreos-config/refs/heads/testing-devel/fedora.repo"
#sed -i \
#-e "s@- (BaseOS|AppStream)@& - Compose@" \
#-e "s@\(baseos\|appstream\)@&-compose@" \
#/etc/yum.repos.d/compose.repo
#cat /etc/yum.repos.d/compose.repo
