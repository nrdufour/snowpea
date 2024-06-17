#!/usr/bin/env bash

set -e

hosts=($(echo $(nix eval .#nixosConfigurations --apply 'pkgs: builtins.concatStringsSep " " (builtins.attrNames pkgs)') | xargs))
## Skipping opi01|2|3 because it has to be build on the host
## TODO: need to add options for that
skip=(
    "genpi4" "opi01" "opi02" "opi03"
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
        nixos-rebuild switch -j auto --use-remote-sudo --target-host $fqdn --flake ".#$host"
    else
        echo "--- Deploying to $fqdn with reboot"
        nixos-rebuild boot -j auto --use-remote-sudo --target-host $fqdn --flake ".#$host"
        ssh $fqdn 'sudo reboot'
    fi
    echo
    echo
done
