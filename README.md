# SnowPea

Managing raspberry pi (3 & 4) via nixos flakes.
(Maybe, I will add Orange Pi 5 plus to it if doable...)

The goals are:

+ produce a generic sdcard image to be able to properly boot (done)
+ produce any sdcard image that would be dedicated to a give purpose
+ help with deploy remotely (via deploy-rs maybe)

## Usage

+ `base`: common settings for all images
+ `generic`: actual flake to build the image for raspberry 4 type. See `Makefile` in it.

## TODO

+ `apps`: a directory to store appliances
+ `opi5+`: maybe adding support for Orange Pi 5+

Thanks for the inspiration coming from <https://github.com/rjpcasalino/pie>

