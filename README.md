# WiFree Copter RPi image

## The original WiFree Copter image

The [original Raspberry Pi image](https://open-diy-projects.com/topic/raspberry-pi-image-installation-und-verkabelung/) for the WiFree Copter was created by [@EagleEi](https://github.com/EagleEi) in 2016 and is based on Rasbian 8 Jessie lite.
It mainly consists of the `create_ap` and `wifree` services. `create_ap` sets up a Wifi network (SSID: WF-xxxxxx, password: 123412341234) and a DHCP server so that your Mobile phone can connect to it.
`wifree` is an HTTP server that builds the bridge between the WiFree Android app and the Flight Controller (FC).
To communicate with the FC, the [MSPv1](https://ardupilot.org/copter/docs/common-msp-overview.html) protocol over serial (9600 8n1) is used.

## What's new in this image

Many users (including me) couldn't upgrade to newer FC firmwares using the original RPi image.
The reason being that newer FC firmwares switched to [MSPv2](https://github.com/iNavFlight/inav/wiki/MSP-V2).
To address this I added a `msp_v2()` function in `msp.rb` that is now used for the communication.
I also switched to 115200 baud. 

This image is now based on Rasbian 9 Stretch lite. 
It could easily be based on the most recent Rasbian (Bullseye by the time of writing), but it turned out that for newer Linux kernels 5.x, the drivers for the onboard Wifi shows no signal strenghts for the connected clients in AP mode anymore. 
So, I decided to use the last Rasbian that comes with a 4.x kernel - Rasbian 9 Stretch.

What's missing is the the read-only root file system and the 2 separate data and video partitions. Maybe that will come later.

I tested the image successfully with Betaflight 4.3.1 and an OMNIBUS F4 Pro (V2) flight controller.

## Build

You can build your own SD image of Raspbian for the WiFree Copter on your local ARM compatible machine (tested on Macbook M1) using [Docker Desktop](https://www.docker.com/get-started/).
After installing Docker, you should tune it a bit to speed up the build process:

 - increase resources to e.g. 8 CPUs
 - enable Experimental Features -> Enable VirtuoFS accelerated directory sharing

Then create the requried docker images with:

```
make docker-build
```

and after that build the images with

```
make all
```

The final image will be written into the folder `images` and is has a filename that includes a recent UTC date
`raspios-stretch-armhf-lite_2022xxxx-xxxxxx.img`. Simply burn that image to a microSD card using [balenaEtcher](https://www.balena.io/etcher/) and boot.

