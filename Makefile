BOARD?=cs

# # Latest (Debian 11 Bullseye)
# IMG=raspios-bullseye-armhf-lite
# IMG_URL=https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2022-09-26/2022-09-22-raspios-bullseye-armhf-lite.img.xz
# BRANCH=rpi-5.19.y

# # Legacy (Debian 10 Buster)
# IMG=raspios-buster-armhf-lite
# IMG_URL=https://downloads.raspberrypi.org/raspios_oldstable_lite_armhf/images/raspios_oldstable_lite_armhf-2022-09-26/2022-09-22-raspios-buster-armhf-lite.img.xz
# BRANCH=rpi-5.19.y

# Old Legacy (Debian 9 Stretch) uses kernel 4.x which supports signal strength monitoring in AP mode for the onboard wifi
IMG=raspios-stretch-armhf-lite
IMG_URL=https://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2019-04-09/2019-04-08-raspbian-stretch-lite.zip
BRANCH=rpi-4.14.y

KERNEL=kernel
DOCKERFILE=Dockerfile

all: build-image

clean:
	rm images/${IMG}_*.img

# Disable custom kernel building as we want an old kernel, see above.
# docker-build db: docker-build-kernel docker-build-image
docker-build db: docker-build-image

.PHONY: docker-build-kernel
docker-build-kernel:
	DOCKER_BUILDKIT=1 \
		docker build \
		--file ${DOCKERFILE} \
		--progress=plain \
		--build-arg KERNEL=${KERNEL} \
		--build-arg BRANCH=${BRANCH} \
		--target build-kernel \
		-t build-${KERNEL}-${BRANCH} \
		.

.PHONY: docker-build-image
docker-build-image dbi:
	DOCKER_BUILDKIT=1 \
		docker build \
		--file ${DOCKERFILE} \
		--progress=plain \
		--target build-image \
		-t build-image-wifree \
		.

# images/${IMG}.img:
# 	mkdir -p images
# 	cd images; \
# 	curl ${IMG_URL} -o ${IMG}.img.xz; \
# 	xz -d ${IMG}.img.xz

images/${IMG}.img:
	mkdir -p images
	curl ${IMG_URL} -o images/${IMG}.img.zip
	unzip -p images/${IMG}.img.zip > $@
	rm images/${IMG}.img.zip

.PHONY: build-kernel bk
build-kernel bk images/${IMG}_${BRANCH}.img: images/${IMG}.img
	docker run --rm \
		--name build-kernel \
		--volume ${PWD}/images:/images \
		--privileged \
		build-${KERNEL}-${BRANCH} \
		/bin/bash -c "KERNEL=${KERNEL} ./build-kernel.sh YES /images/${IMG}.img && mv ${IMG}_kernel.img /images/${IMG}_${BRANCH}.img"

.PHONY: build-image bi
build-image bi: images/${IMG}.img
	docker run --rm \
		--name build-image-wifree \
		--volume ${PWD}/images:/images \
		--privileged \
		build-image-wifree \
		/bin/bash -c "./build-image.sh YES /images/${IMG}.img ${BOARD} && mv ${IMG}_* /images/"
