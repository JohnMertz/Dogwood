# Allow build files to be referenced without being copied into the final image
FROM scratch AS context
COPY system_files /system_files
COPY build_files /build_files

# Kernel + Modules image
FROM ghcr.io/ublue-os/akmods:coreos-stable-43 AS akmods

## Base Image
FROM ghcr.io/ublue-os/base-main:latest

## Make /opt immutable 
RUN rm /opt && mkdir /opt

## Required ENV variables
ARG MAJOR_VERSION="${MAJOR_VERSION:-43}"
ARG VARIANT="${VARIANT:-desktop}"
ARG TAG="${TAG:-latest}"
ARG VERSION="${VERSION:-00.00000000}"
ARG SHA_HEAD_SHORT="${SHA_HEAD_SHORT:-deadbeef}"

## Build image
RUN --mount=type=cache,dst=/var/cache/libdnf5 \
  --mount=type=cache,dst=/var/cache/rpm-ostree \
  --mount=type=bind,from=context,source=/,target=/run/context \
  --mount=type=bind,from=akmods,src=/,dst=/tmp/akmods/ \
  --mount=type=secret,id=GITHUB_TOKEN \
  /run/context/build_files/build.sh

## Verify final image and contents are correct.
RUN bootc container lint
