#!/usr/bin/env bash

# This file needs to exist otherwise running this in a RUN label makes it so bash strict mode doesnt work.
# Thus leading to silent failures

set -eo pipefail

# Do not rely on any of these scripts existing in a specific path
# Make the names as descriptive as possible and everything that uses dnf for package installation/removal should have `packages-` as a prefix.

CONTEXT_PATH="$(realpath "$(dirname "$0")/..")" # should return /run/context
BUILD_FILES_PATH="$(realpath "$(dirname "$0")")"
MAJOR_VERSION_NUMBER="$(sh -c '. /usr/lib/os-release ; echo ${VERSION_ID%.*}')"
SCRIPTS_PATH="$(realpath "$(dirname "$0")/scripts")"
export SCRIPTS_PATH
export MAJOR_VERSION_NUMBER

# Copy in system files
rsync -rvK $CONTEXT_PATH/system_files/ /

# Copy in all files from build_files to $CONTEXT_PATH
printf "::group:: ===%s-file-copying===\n" "${CONTEXT_PATH}"
cp -avf "${CONTEXT_PATH}" /
printf "::endgroup::\n"

# Execute all scripts numbered scripts (like: 00-name.sh) which have been copied in
find "${BUILD_FILES_PATH}" -maxdepth 1 -iname "*-*.sh" -type f -print0 | sort --zero-terminated --sort=human-numeric | while IFS= read -r -d $'\0' script; do
  printf "::group:: ===${CONTEXT_PATH}/%s===\n" "$(basename "$script")"
  "$(realpath $script)"
  printf "::endgroup::\n"
done

# Actions which must be run at the _end_ of the build
${BUILD_FILES_PATH}/disable-repos.sh
${BUILD_FILES_PATH}/cleanup.sh
