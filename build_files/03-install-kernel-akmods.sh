#!/usr/bin/bash

set -eoux pipefail

# Remove Existing Kernel
for pkg in kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra; do
  rpm --erase $pkg --nodeps
done

# Install Kernel
dnf5 -y install \
  /tmp/akmods/kernel-rpms/kernel-[0-9]*.rpm \
  /tmp/akmods/kernel-rpms/kernel-core-*.rpm \
  /tmp/akmods/kernel-rpms/kernel-modules-*.rpm

# TODO: Figure out why akmods cache is pulling in akmods/kernel-devel
dnf5 -y install \
  /tmp/akmods/kernel-rpms/kernel-devel-*.rpm

dnf5 versionlock add kernel kernel-devel kernel-devel-matched kernel-core kernel-modules kernel-modules-core kernel-modules-extra

# NOTE: we won't use dnf5 copr plugin for ublue-os/akmods until our upstream provides the COPR standard naming
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/_copr_ublue-os-akmods.repo

dnf5 -y install \
  /tmp/akmods/rpms/kmods/*xone*.rpm \
  /tmp/akmods/rpms/kmods/*openrazer*.rpm \
  /tmp/akmods/rpms/kmods/*framework-laptop*.rpm
dnf5 -y install \
  https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-"$(rpm -E %fedora)".noarch.rpm \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-"$(rpm -E %fedora)".noarch.rpm
dnf5 -y install \
  v4l2loopback /tmp/akmods/rpms/kmods/*v4l2loopback*.rpm
dnf5 -y remove rpmfusion-free-release rpmfusion-nonfree-release

sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_ublue-os-akmods.repo

# /*
### Version Lock kernel packages
# */
dnf versionlock add \
  kernel \
  kernel-core \
  kernel-modules \
  kernel-modules-core \
  kernel-modules-extra
