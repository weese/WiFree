BOARD?=cs

# Latest
IMG=raspios-bullseye-armhf-lite
IMG_URL=https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2022-09-26/2022-09-22-raspios-bullseye-armhf-lite.img.xz
BRANCH=rpi-5.19.y
KERNEL=kernel
DOCKERFILE=Dockerfile

all: build-image

clean:
	rm images/${IMG}_*.img

docker-build db: docker-build-kernel docker-build-image

.PHONY: docker-build-kernel
docker-build-kernel:
	DOCKER_BUILDKIT=1 \
		docker build \
		--file ${DOCKERFILE} \
		--progress=plain \
		--build-arg TARGET=${TARGET} \
		--build-arg BRANCH=${BRANCH} \
		--target build-kernel \
		-t build-${TARGET}-${BRANCH} \
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

images/${IMG}.img:
	mkdir -p images
	cd images; \
	curl ${IMG_URL} -o ${IMG}.img.xz; \
	xz -d ${IMG}.img.xz

.PHONY: build-kernel bk
build-kernel bk images/${IMG}_${BRANCH}.img: images/${IMG}.img
	docker run --rm \
		--name build-kernel \
		--volume ${PWD}/images:/images \
		--privileged \
		build-${TARGET}-${BRANCH} \
		/bin/bash -c "KERNEL=${KERNEL} ./build-kernel.sh YES /images/${IMG}.img && mv ${IMG}_kernel.img /images/${IMG}_${BRANCH}.img"

.PHONY: build-image bi
build-image bi: images/${IMG}_${BRANCH}.img
	docker run --rm \
		--name build-image-wifree \
		--volume ${PWD}/images:/images \
		--privileged \
		build-image-wifree \
		/bin/bash -c "./build-image.sh YES /images/${IMG}_${BRANCH}.img ${BOARD} && mv ${IMG}_* /images/"
