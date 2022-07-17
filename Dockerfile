FROM debian:bullseye AS base

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get clean && apt-get update && \
    apt-get install -y \
    git bc bison flex libssl-dev python3 make kmod libc6-dev libncurses5-dev \
    crossbuild-essential-armhf \
    crossbuild-essential-arm64 \
    vim wget kpartx rsync sudo util-linux cloud-guest-utils

RUN mkdir /build
RUN mkdir -p /mnt/ext4

WORKDIR /build

CMD ["bash"]


# Extend image for WiFree Copter
FROM base AS build-image
VOLUME /build/images

COPY build/build-image.sh .
COPY install.sh /
COPY fs /root/

CMD ["bash"]
