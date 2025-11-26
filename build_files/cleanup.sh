#!/usr/bin/env bash

set -xeuo pipefail

# Image cleanup

dnf clean all

rm -rf /.gitkeep
find /var/* -maxdepth 0 -type d \! -name cache -exec rm -fr {} \;
find /var/cache/* -maxdepth 0 -type d \! -name libdnf5 \! -name rpm-ostree -exec rm -fr {} \;
find /boot -mindepth 1 -delete
mkdir -p /var/tmp /boot

# Make /usr/local writeable
mv /usr/local /var/usrlocal
ln -s /var/usrlocal /usr/local

# We need this else anything accessing image-info fails
# FIXME: Figure out why this doesnt have the right permissions by default
chmod 644 /usr/share/ublue-os/image-info.json

KERNEL_SUFFIX=""
QUALIFIED_KERNEL="$(rpm -qa | grep -P 'kernel-(|'"$KERNEL_SUFFIX"'-)(\d+\.\d+\.\d+)' | sed -E 's/kernel-(|'"$KERNEL_SUFFIX"'-)//')"
export DRACUT_NO_XATTR=1
/usr/bin/dracut --no-hostonly --kver "$QUALIFIED_KERNEL" --reproducible -v --add ostree -f "/lib/modules/$QUALIFIED_KERNEL/initramfs.img"
chmod 0600 "/lib/modules/$QUALIFIED_KERNEL/initramfs.img"

# FIXME: use --fix option once https://github.com/containers/bootc/pull/1152 is merged
bootc container lint --fatal-warnings || true
