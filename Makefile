BOARD?=cs

# Latest
TARGET=cm3
IMG=raspios-bullseye-armhf-lite
IMG_URL=https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2022-04-07/2022-04-04-raspios-bullseye-armhf-lite.img.xz
FLAVOR=wifree

all: build-image

clean:
	rm images/${IMG}_*.img

docker-build db: docker-build-kernel docker-build-image

.PHONY: docker-build-image
docker-build-image dbi:
	DOCKER_BUILDKIT=1 \
		docker build --progress=plain \
		--target build-image \
		-t build-image-wifree \
		.

images/${IMG}.img:
	mkdir -p images
	cd images; \
	curl ${IMG_URL} -o ${IMG}.img.xz; \
	xz -d ${IMG}.img.xz

.PHONY: build-image bi
build-image bi: images/${IMG}.img
	docker run --rm \
		--name build-image-wifree \
		--volume ${PWD}/images:/build/images \
		--privileged \
		build-image-wifree \
		/bin/bash -c "./build-image.sh YES /build/images/${IMG}.img && mv ${IMG}_* /build/images/"
