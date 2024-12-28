#!/usr/bin/env bash

HOST=$1
USER=ndufour

nixos-rebuild switch \
  -v \
  --flake ".#${HOST}" \
  --fast \
  --use-remote-sudo \
  --build-host "${USER}"@"${HOST}.internal" \
  --target-host "${USER}"@"${HOST}.internal"
