# SnowPea

NixOS Flake to manage home machines.

## Overview

My home infrastructure is mostly based on 3 types of machines:

+ raspberry pi 3
+ raspbbery pi 4
+ orange pi 5 plus

Those are aranged in a kubernetes cluster, plus a few of them used to provide outside services, like gitea or being a mini NAS. So everything is basically arm based.

## Goals

+ be able to produce sdcard images for raspberry based machines [done]
+ be able to produce sdcard images for orange pi 5 plus [done]
+ master all machines in that flake [done]
+ have fun and learn more Nix/NixOS [in progress -- will never end :-)]

## Thanks

+ for the general inspiration coming from <https://github.com/rjpcasalino/pie>
+ <https://github.com/bjw-s/nix-config> for the remote-rebuild.sh script.
+ <https://github.com/truxnell/nix-config> for the amazing structure/design I'm now using
+ <https://github.com/anthr76/snowflake> for the first flake ;-)

