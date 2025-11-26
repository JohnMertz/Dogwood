#!/usr/bin/env bash

set -xeuo pipefail

#Add the Flathub Flatpak remote and remove the Fedora Flatpak remote
flatpak remote-add --system --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
systemctl disable flatpak-add-fedora-repos.service
systemctl mask flatpak-add-fedora-repos.service
rm -f /usr/lib/systemd/system/flatpak-add-fedora-repos.service

flatpak install -y $(cat /run/context/system_files/etc/dogwood/system-flatpaks.list) \
  io.podman_desktop.PodmanDesktop \
  io.github.getnf.embellish \
  io.github.dvlv.boxbuddyrs
