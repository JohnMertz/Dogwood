#!/usr/bin/env bash

set -xeuo pipefail

/usr/sbin/depmod -a $(ls -1 /lib/modules/ | tail -1)

# Adding missing systemd tmpfiles and sysusers
cat >/usr/lib/tmpfiles.d/bootc-dirs.conf <<EOF
d /var/cache/libdnf5 0755 root root - -
d /var/cache/rpm-ostree 0755 root root - -
EOF
cat >/usr/lib/sysusers.d/plugdev.conf <<EOF
u plugdev - "Pluggable Devices"
EOF

# Generate initramfs image
# Add resume module so that hibernation works
echo "add_dracutmodules+=\" resume \"" >/etc/dracut.conf.d/resume.conf
KERNEL_SUFFIX=""
QUALIFIED_KERNEL="$(rpm -qa | grep -P 'kernel-(|'"$KERNEL_SUFFIX"'-)(\d+\.\d+\.\d+)' | sed -E 's/kernel-(|'"$KERNEL_SUFFIX"'-)//' | tail -n 1)"
/usr/bin/dracut --no-hostonly --kver "$QUALIFIED_KERNEL" --reproducible --zstd -v --add ostree -f "/lib/modules/$QUALIFIED_KERNEL/initramfs.img"
