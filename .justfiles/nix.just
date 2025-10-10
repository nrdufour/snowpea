# Nix-related commands

# Update the inputs in the flake.lock file
nix-update:
    nix flake update

# Check the flake is ok
nix-check:
    nix flake check

# List the NixOS hosts in the flake
nix-list-hosts:
    @nix flake show --json 2>/dev/null | jq -r '.nixosConfigurations | keys.[]'

# Deploy the configuration of a given host
nix-deploy host:
    nixos-rebuild switch -j auto --use-remote-sudo --build-host {{host}}.internal --target-host {{host}}.internal --flake ".#{{host}}" --fast

# Deploy flake to all nodes (with confirmation)
nix-deploy-all:
    #!/usr/bin/env bash
    set -euo pipefail

    # Check prerequisites
    if ! command -v nix &> /dev/null; then
        echo "Error: nix not found"
        exit 1
    fi
    if ! command -v nixos-rebuild &> /dev/null; then
        echo "Error: nixos-rebuild not found"
        exit 1
    fi

    echo "This will deploy the local flake to all whitelisted hosts."
    read -p "Do you want to continue applying this configuration? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 1
    fi

    # Get all hosts and deploy to each
    HOSTS=$(nix flake show --json 2>/dev/null | jq -r '.nixosConfigurations | keys.[]')
    for HOST in $HOSTS; do
        echo "Deploying to $HOST..."
        nixos-rebuild switch -j auto --use-remote-sudo --build-host ${HOST}.internal --target-host ${HOST}.internal --flake ".#${HOST}" --fast
    done
