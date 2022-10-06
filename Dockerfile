FROM debian:bullseye AS base

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get clean && apt-get update && \
    apt-get install -y \
    git bc bison flex libssl-dev python3 make kmod libc6-dev libncurses5-dev \
    crossbuild-essential-armhf \
    crossbuild-essential-arm64 \
    vim wget kpartx rsync sudo util-linux cloud-guest-utils

RUN mkdir /build
RUN mkdir -p /mnt/fat32
RUN mkdir -p /mnt/ext4

WORKDIR /build

CMD ["bash"]


# Cross compile kernel
FROM base AS build-kernel
ARG TARGET
ARG BRANCH
VOLUME /images

WORKDIR /usr/src

RUN --mount=type=cache,target=/usr/src/linux/ \
  rm -rf linux; \
  git clone --depth=1 https://github.com/raspberrypi/linux --branch ${BRANCH}
COPY build/* .
RUN --mount=type=cache,target=/usr/src/linux/ \
  ./compile-kernel.sh $TARGET -j8 ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-
RUN apt-get install -y fdisk

CMD ["bash"]


# Extend image for WiFree Copter
FROM base AS build-image
VOLUME /images

COPY build/* .
COPY install.sh /
RUN mkdir -p /home/pi/WiFree
COPY . /home/pi/Wifree

CMD ["bash"]
