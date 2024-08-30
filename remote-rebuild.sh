#!/usr/bin/env bash

FLAKE=${1}
USER=${2}
TARGET=${3}

nixos-rebuild switch \
  -v \
  --flake ".#${FLAKE}" \
  --fast \
  --use-remote-sudo \
  --build-host "${USER}"@"${TARGET}" \
  --target-host "${USER}"@"${TARGET}"
