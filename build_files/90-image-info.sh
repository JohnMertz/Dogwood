#!/usr/bin/env bash

set -xeuo pipefail

cat >/usr/share/ublue-os/image-info.json <<EOF
{
  "image-name": "dogwood",
  "image-ref": "ostree-image-signed:docker://ghcr.io/johnmertz/dogwood",
  "image-vendor": "johnmertz",
  "image-flavor": "${VARIANT}",
  "image-tag": "${TAG}",
  "fedora-version": "${MAJOR_VERSION}"
  "base-image-name": "ublue-os/base-main",
}
EOF

OLD_PRETTY_NAME="$(sh -c '. /usr/lib/os-release ; echo $NAME $VERSION')"
# Get VERSION from Fedora unless defined
if [ -z $VERSION ]; then
  VERSION="$(echo $OLD_PRETTY_NAME | sed 's|[a-zA-Z ]*\([0-9]*\.[0-9]*\).*|\1|')"
fi

# OS Release File (changed in order with upstream)
sed -i -f - /usr/lib/os-release <<EOF
s/^NAME=.*/NAME=\"Dogwood\"/
s|^VERSION_CODENAME=.*|VERSION_CODENAME=\"Dogwood ${MAJOR_VERSION}\"|
s|^ID=.*|ID=\"dogwood\"\nID_LIKE=\"fedora\"|
s/^VARIANT_ID=.*/VARIANT_ID=dogwood-${VARIANT}/
s/^PRETTY_NAME=.*/PRETTY_NAME=\"Dogwood (FROM ${OLD_PRETTY_NAME})\"/
s|^HOME_URL=.*|HOME_URL=\"https://github.com/JohnMertz/Dogwood\"|
s|^DOCUMENTATION_URL=.*|DOCUMENTATION_URL=\"https://github.com/JohnMertz/Dogwood/wiki\"|
s|^SUPPORT_URL=.*|SUPPORT_URL=\"https://github.com/JohnMertz/Dogwood/discussions\"|
s|^BUG_REPORT_URL=.*|BUG_REPORT_URL=\"https://github.com/JohnMertz/Dogwood/issues\"|
s|^CPE_NAME=\"cpe:/o:fedora:fedora|CPE_NAME=\"cpe:/o:dogwood:${VARIANT}|
s|^DEFAULT_HOSTNAME=.*|DEFAULT_HOSTNAME=\"dogwood\"|
s|^VERSION=.*|VERSION=\"${VERSION}\"|
s|^OSTREE_VERSION=.*|OSTREE_VERSION=\'${VERSION}\'|

/^REDHAT_BUGZILLA_PRODUCT=/d
/^REDHAT_BUGZILLA_PRODUCT_VERSION=/d
/^REDHAT_SUPPORT_PRODUCT=/d
/^REDHAT_SUPPORT_PRODUCT_VERSION=/d
/^VERSION_CODENAME=/d
EOF

tee -a /usr/lib/os-release <<EOF
DOCUMENTATION_URL="https://github.com/JohnMertz/Dogwood/wiki"
SUPPORT_URL="https://github.com/JohnMertz/Dogwood/discussions"
BUG_REPORT_URL="https://github.com/JohnMertz/Dogwood/issues"
DEFAULT_HOSTNAME="dogwood"
BUILD_ID="${SHA_HEAD_SHORT:-deadbeef}"
IMAGE_ID="dogwood-${VARIANT}"
IMAGE_VERSION="${VERSION}"
EOF

# Fix issues caused by ID no longer being fedora
sed -i "s|^EFIDIR=.*|EFIDIR=\"fedora\"|" /usr/sbin/grub2-switch-to-blscfg

echo "::endgroup::"
