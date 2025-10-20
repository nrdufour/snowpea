# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## About SnowPea

SnowPea is a NixOS Flake for managing home infrastructure consisting primarily of ARM-based single-board computers (Raspberry Pi 3/4, Orange Pi 5 Plus) arranged in Kubernetes clusters. The infrastructure includes standalone services and a k3s cluster.

## Commands

### Core Development
- `just lint` - Run statix lint to check Nix code quality
- `just format` - Format project files using nixpkgs-fmt
- `nix flake check` or `just nix-check` - Validate the flake configuration
- `nix flake update` or `just nix-update` - Update flake inputs (flake.lock)

### Host Management
- `just nix-list-hosts` - List all configured NixOS hosts
- `just nix-deploy <hostname>` - Deploy configuration to a specific host
- `just nix-deploy-all` - Deploy configuration to all hosts (with confirmation prompt)

### SD Card Image Building
- `just sd-build <hostname>` - Build SD card image for a host
- `just sd-flash <hostname>` - Build and flash SD card image using rpi-imager

### Secrets Management
- `just sops-update` - Update all SOPS encrypted secrets

## Architecture

### Flake Structure
The flake.nix defines a `mkNixosConfig` function that standardizes machine configuration by combining:
- **baseModules**: Core modules including global profile, nixos modules, and host-specific config
- **hardwareModules**: Hardware-specific configurations (e.g., SD card images, hardware profiles)
- **profileModules**: Role-based configurations (server, k3s-controller, k3s-worker)

### Directory Organization
- `nixos/profiles/` - Reusable configuration profiles:
  - Hardware profiles: `hw-rpi3.nix`, `hw-rpi4.nix`, `hw-orangepi5plus.nix`, `hw-acer-minipc.nix`
  - Role profiles: `role-server.nix`, `role-k3s-controller.nix`, `role-k3s-worker.nix`
  - `global.nix` - Base configuration applied to all machines
- `nixos/hosts/` - Host-specific configurations for each machine
- `nixos/modules/nixos/` - Custom NixOS modules for services and system configuration
- `.justfiles/` - Just recipes organized by domain (nix, sops, sd)

### Machine Categories
- **Standalone Servers**: eagle, mysecrets, possum, beacon, routy, cardinal
- **k3s Controllers**: opi01, opi02, opi03 (Orange Pi 5 Plus)
- **k3s Workers**: raccoon00-raccoon05 (Raspberry Pi 4)

### Key Technologies
- NixOS 25.05 with flakes
- SOPS for secrets management
- k3s for Kubernetes orchestration
- Just command runner for automation
- ARM64 and x86_64 architectures

## Development Workflow

When modifying configurations:
1. Make changes to the appropriate profile, host config, or module
2. Run `just lint` and `just format` to ensure code quality
3. Test with `just nix-check` to validate the flake
4. Deploy to specific host with `just nix-deploy <hostname>`
5. For new SD card images, use `just sd-build <hostname>`

Host configurations automatically inherit the global profile and appropriate hardware/role modules based on their flake.nix definition.