#!/bin/bash

set -xeuo pipefail

# Prevent Distrobox containers from being updated via the background service
sed -i 's|uupd|& --disable-module-distrobox|' /usr/lib/systemd/system/uupd.service

# Enable sleep then hibernation by DEFAULT!
sed -i 's/#HandleLidSwitch=.*/HandleLidSwitch=suspend-then-hibernate/g' /usr/lib/systemd/logind.conf
sed -i 's/#HandleLidSwitchDocked=.*/HandleLidSwitchDocked=suspend-then-hibernate/g' /usr/lib/systemd/logind.conf
sed -i 's/#HandleLidSwitchExternalPower=.*/HandleLidSwitchExternalPower=suspend-then-hibernate/g' /usr/lib/systemd/logind.conf
sed -i 's/#SleepOperation=.*/SleepOperation=suspend-then-hibernate/g' /usr/lib/systemd/logind.conf

# Setup Services
for service in $(find /run/context/system_files/usr/lib/systemd/user -type f); do
  systemctl --global enable $(basename $service)
done
systemctl --global enable podman-auto-update.timer
systemctl --global enable ublue-user-setup.service

for service in $(find /run/context/system_files/usr/lib/systemd/system -type f); do
  systemctl enable $(basename $service)
done
systemctl enable brew-setup.service
systemctl enable brew-update.timer
systemctl enable brew-upgrade.timer
systemctl enable check-sb-key.service
systemctl enable fwupd.service
systemctl enable input-remapper.service
systemctl disable mcelog.service
systemctl enable podman.socket
systemctl enable rpm-ostree-countme.service
systemctl enable sshd.service
systemctl enable tailscaled.service
systemctl enable ublue-system-setup.service

# Swap updaters
#systemctl disable rpm-ostree.service
systemctl disable rpm-ostreed-automatic.timer
systemctl disable flatpak-system-update.timer
systemctl enable uupd.timer
#systemctl mask bootc-fetch-apply-updates.timer bootc-fetch-apply-updates.service

# Disable lastlog display on previous failed login in GDM (This makes logins slow)
authselect enable-feature with-silent-lastlog

# Enable polkit rules for fingerprint sensors via fprintd
authselect enable-feature with-fingerprint

sed -i -e "s@PrivateTmp=.*@PrivateTmp=no@g" /usr/lib/systemd/system/systemd-resolved.service
# FIXME: this does not yet work, the resolution service fails for some reason
# enable systemd-resolved for proper name resolution
systemctl enable systemd-resolved.service

if [[ $VARIANT == 'desktop' ]]; then
  systemctl enable swtpm-workaround.service
  systemctl enable libvirt-workaround.service
fi
