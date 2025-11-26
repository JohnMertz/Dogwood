#!/usr/bin/env bash

set -xeuo pipefail

cat >/usr/share/ublue-os/image-info.json <<EOF
{
  "image-name": "${IMAGE_NAME}",
  "image-ref": "ostree-image-signed:docker://ghcr.io/${IMAGE_VENDOR}/${IMAGE_NAME}",
  "image-flavor": "${VARIANT}",
  "image-vendor": "${IMAGE_VENDOR}",
  "image-tag": "${IMAGE_TAG}",
  "fedora-version": "${MAJOR_VERSION}"
  "base-image-name": "${SOURCE_VENDOR}/${SOURCE_IMAGE}",
}
EOF

IMAGE_LIKE="fedora"
OLD_PRETTY_NAME="$(sh -c '. /usr/lib/os-release ; echo $NAME $VERSION')"
IMAGE_PRETTY_NAME="Dogwood"
HOME_URL="https://github.com/JohnMertz/Dogwood"
DOCUMENTATION_URL="https://github.com/JohnMertz/Dogwood/wiki"
SUPPORT_URL="https://github.com/JohnMertz/Dogwood/discussions"
BUG_SUPPORT_URL="https://github.com/JohnMertz/Dogwood/issues"
VERSION="${VERSION:-00.00000000}"

# OS Release File (changed in order with upstream)
sed -i -f - /usr/lib/os-release <<EOF
s/^NAME=.*/NAME=\"${IMAGE_PRETTY_NAME}\"/
s|^VERSION_CODENAME=.*|VERSION_CODENAME=\"Dogwood ${MAJOR_VERSION}\"|
s|^ID=.*|ID=\"${IMAGE_PRETTY_NAME}\"\nID_LIKE=\"fedora\"|
s/^VARIANT_ID=.*/VARIANT_ID=${VARIANT}/
s/^PRETTY_NAME=.*/PRETTY_NAME=\"${IMAGE_PRETTY_NAME} (FROM ${OLD_PRETTY_NAME})\"/
s|^HOME_URL=.*|HOME_URL=\"${HOME_URL}\"|
s|^SUPPORT_URL=.*|SUPPORT_URL=\"$SUPPORT_URL\"|
s|^BUG_REPORT_URL=.*|BUG_REPORT_URL=\"${BUG_SUPPORT_URL}\"|
s|^CPE_NAME=\"cpe:/o:fedora:fedora|CPE_NAME=\"cpe:/o:dogwood:${VARIANT}|
s|^DEFAULT_HOSTNAME=.*|DEFAULT_HOSTNAME=\"${IMAGE_NAME}\"|
s|^VERSION=.*|VERSION=\"${VERSION}\"|
s|^OSTREE_VERSION=.*|OSTREE_VERSION=\'${VERSION}\'|

/^REDHAT_BUGZILLA_PRODUCT=/d
/^REDHAT_BUGZILLA_PRODUCT_VERSION=/d
/^REDHAT_SUPPORT_PRODUCT=/d
/^REDHAT_SUPPORT_PRODUCT_VERSION=/d
/^VERSION_CODENAME=/d
EOF

tee -a /usr/lib/os-release <<EOF
DOCUMENTATION_URL="${DOCUMENTATION_URL}"
SUPPORT_URL="${SUPPORT_URL}"
DEFAULT_HOSTNAME="dogwood"
BUILD_ID="${SHA_HEAD_SHORT:-deadbeef}"
IMAGE_ID="${IMAGE_NAME}"
IMAGE_VERSION="${VERSION}"
EOF

# Fix issues caused by ID no longer being fedora
sed -i "s|^EFIDIR=.*|EFIDIR=\"fedora\"|" /usr/sbin/grub2-switch-to-blscfg

echo "::endgroup::"
