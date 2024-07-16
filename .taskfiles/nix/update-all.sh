#!/usr/bin/env bash

set -e

hosts=($(echo $(nix eval .#nixosConfigurations --apply 'pkgs: builtins.concatStringsSep " " (builtins.attrNames pkgs)') | xargs))

## Skipping some hosts
# genpi4 is a generic image, not a host
# possum isn't ready
skip=(
    "genpi4" "possum"
)

reboot=0

while getopts ":r" option; do
    case $option in
    r)
        reboot=1
        ;;
    esac
done

for host in "${hosts[@]}"; do
    # Check if the host is in the skip list
    if [[ " ${skip[*]} " =~ " ${host} " ]]; then
        continue
    fi
    fqdn="$host.internal"
    if [ $reboot -eq 0 ]; then
        echo "--- Deploying to $fqdn"
        nixos-rebuild switch -j auto --use-remote-sudo --build-host $fqdn --target-host $fqdn --flake ".#$host"
    else
        echo "--- Deploying to $fqdn with reboot"
        nixos-rebuild boot -j auto --use-remote-sudo --build-host $fqdn --target-host $fqdn --flake ".#$host"
        ssh $fqdn 'sudo reboot'
    fi
    echo
    echo
done
