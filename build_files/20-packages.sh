#!/bin/bash

set -xeuo pipefail

source /run/context/build_files/copr-helpers.sh

dnf -y remove \
  setroubleshoot

# Configure additional repositories (only enabled when installing)
dnf -y copr enable ublue-os/packages
dnf -y copr disable ublue-os/packages

DESKTOP_PACKAGES=""
if [[ $VARIANT == 'desktop' ]]; then
  DESKTOP_PACKAGES="
  acpi
  alacritty
  android-tools
  blueman
  buildah
  clipman
  distrobox
  firewalld
  fpaste
  fprintd-pam
  fwupd
  fzf
  gphoto2
  grim
  gvfs
  gvfs-fuse
  gvfs-goa
  gvfs-gphoto2
  gvfs-nfs
  gvfs-mtp
  gvfs-smb
  hdparm
  hplip
  input-remapper
  kanshi
  libcamera
  libcamera-gstreamer
  libcamera-tools
  libcamera-v4l2
  libsane-hpaio
  libvirt
  libvirt-daemon
  libvirt-daemon-kvm
  libvirt-nss
  mesa-dri-drivers
  mesa-vulkan-drivers
  mpv-libs
  network-manager-applet
  NetworkManager-adsl
  nss-mdns
  ntfs-3g
  pavucontrol
  pinentry-tty
  pipewire
  pipewire-v4l2
  playerctl
  plymouth
  plymouth-system-theme
  podman-gvproxy
  podman-machine
  powertop
  power-profiles-daemon
  pulseaudio-utils
  p11-kit-server
  qemu-guest-agent
  qemu-kvm
  qemu-system-x86
  sane-backends-drivers-scanners
  sway
  swaybg
  swayidle
  swaylock
  system-config-printer
  system-reinstall-bootc
  systemd
  systemd-container
  systemd-oomd-defaults
  systemd-resolved
  tmux
  Thunar
  thunar-archive-plugin
  thunar-volman
  tuned
  tumbler
  usbutils
  virt-install
  virt-manager
  waybar
  wev
  wlsunset
  wireguard-tools
  wireplumber
  xarchiver
  xdg-dbus-proxy
  xdg-user-dirs-gtk
  xdg-desktop-portal-gtk
  xdg-desktop-portal-wlr
  xdg-user-dirs
  xfce-polkit
  xhost
  xorg-x11-server-Xwayland
  ydotool
  yelp-tools"
fi

# Install all packages
dnf -y install --setopt=install_weak_deps=False --allowerasing \
  --enablerepo copr:copr.fedorainfracloud.org:ublue-os:packages \
  btrfs-progs \
  bolt \
  dnf5-plugins \
  duperemove \
  fastfetch \
  just \
  jq \
  man-db \
  man-pages \
  micropipenv \
  perl-App-cpanminus \
  podman-compose \
  polkit \
  rclone \
  slurp \
  wl-clipboard \
  yq \
  $DESKTOP_PACKAGES

# Everything that depends on external repositories should be after this.
# Make sure to set them as disabled and enable them only when you are going to use their packages.

dnf config-manager addrepo --from-repofile=https://pkgs.tailscale.com/stable/fedora/tailscale.repo
dnf config-manager setopt tailscale-stable.enabled=0
dnf -y install --setopt=install_weak_deps=False --allowerasing --enablerepo "tailscale-stable" tailscale

copr_install_isolated "alternateved/tofi" "tofi"
copr_install_isolated "che/nerd-fonts" "nerd-fonts"
copr_install_isolated "erikreider/SwayNotificationCenter" "SwayNotificationCenter"
copr_install_isolated "ublue-os/packages" \
  "bazaar" \
  "ublue-os-just" \
  "ublue-os-libvirt-workarounds" \
  "ublue-os-luks" \
  "ublue-os-signing" \
  "ublue-os-udev-rules" \
  "ublue-os-update-services" \
  "ublue-motd" \
  "ublue-fastfetch" \
  "ublue-bling" \
  "ublue-rebase-helper" \
  "ublue-setup-services" \
  "ublue-polkit-rules" \
  "ublue-brew" \
  "uupd"

# Packages to exclude
EXCLUDED_PACKAGES=(
  fedora-bookmarks
  fedora-chromium-config
  fedora-chromium-config-gnome
  firefox
  firefox-langpacks
  gnome-extensions-app
  gnome-shell-extension-background-logo
  gnome-software
  gnome-software-rpm-ostree
  gnome-terminal-nautilus
  yelp
)
# Remove excluded packages if they are installed
if [[ "${#EXCLUDED_PACKAGES[@]}" -gt 0 ]]; then
  readarray -t INSTALLED_EXCLUDED < <(rpm -qa --queryformat='%{NAME}\n' "${EXCLUDED_PACKAGES[@]}" 2>/dev/null || true)
  if [[ "${#INSTALLED_EXCLUDED[@]}" -gt 0 ]]; then
    dnf -y remove "${INSTALLED_EXCLUDED[@]}"
  else
    echo "No excluded packages found to remove."
  fi
fi

# Fix for ID in fwupd
dnf -y copr enable ublue-os/staging
dnf -y copr disable ublue-os/staging
dnf -y swap \
  --repo=copr:copr.fedorainfracloud.org:ublue-os:staging \
  fwupd fwupd

# TODO: remove me on next flatpak release when preinstall landed
if [[ "$(rpm -E %fedora)" -ge "42" ]]; then
  dnf -y copr enable ublue-os/flatpak-test
  dnf -y copr disable ublue-os/flatpak-test
  dnf -y --repo=copr:copr.fedorainfracloud.org:ublue-os:flatpak-test swap flatpak flatpak
  dnf -y --repo=copr:copr.fedorainfracloud.org:ublue-os:flatpak-test swap flatpak-libs flatpak-libs
  dnf -y --repo=copr:copr.fedorainfracloud.org:ublue-os:flatpak-test swap flatpak-session-helper flatpak-session-helper
  # print information about flatpak package, it should say from our copr
  rpm -q flatpak --qf "%{NAME} %{VENDOR}\n" | grep ublue-os
fi

# This is required so homebrew works indefinitely.
# Symlinking it makes it so whenever another GCC version gets released it will break if the user has updated it without-
# the homebrew package getting updated through our builds.
# We could get some kind of static binary for GCC but this is the cleanest and most tested alternative. This Sucks.
dnf -y --setopt=install_weak_deps=False install gcc
