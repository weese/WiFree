FROM debian:bullseye AS base

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get clean && apt-get update && \
    apt-get install -y \
    git bc bison flex libssl-dev python3 make kmod libc6-dev libncurses5-dev \
    crossbuild-essential-armhf \
    crossbuild-essential-arm64 \
    vim wget kpartx fdisk rsync sudo util-linux cloud-guest-utils

RUN mkdir /build
RUN mkdir -p /mnt/fat32
RUN mkdir -p /mnt/ext4

WORKDIR /build

CMD ["bash"]


# Cross compile kernel
FROM base AS build-kernel
ARG KERNEL
ARG BRANCH
VOLUME /images

WORKDIR /usr/src

RUN --mount=type=cache,target=/usr/src/linux/ \
  rm -rf linux; \
  git clone --depth=1 https://github.com/raspberrypi/linux --branch ${BRANCH}
COPY build/* .
RUN --mount=type=cache,target=/usr/src/linux/ \
  ./compile-kernel.sh $KERNEL -j8 ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-

CMD ["bash"]


# Extend image for WiFree Copter
FROM base AS build-image
VOLUME /images

COPY . /build
WORKDIR /build/build

CMD ["bash"]
