# SnowPea 🫛

> **⚠️ ARCHIVED REPOSITORY**
>
> This repository is now archived. All active development has moved to **avalanche**:
> - GitHub: https://github.com/nrdufour/avalanche
> - Internal Forgejo: https://forge.internal/nemo/avalanche

> Because managing a homelab with NixOS flakes is easier than remembering which Pi is which.

A NixOS Flake for wrangling my entire homelab fleet of ARM-based single-board computers (and a couple x86 friends who crashed the party). Everything from Kubernetes clusters to standalone services, all declared in Nix because YOLO.

## TLDR

- 16 machines total (plus ghosts in the config)
- k3s cluster with 3 Orange Pi 5 Plus controllers + 6 Raspberry Pi 4 workers
- Standalone services on various Pis and x86 boxes
- SD card image generation included
- Remote deployment via `just nix-deploy`

## Bill of Materials (Machine Zoo)

### k3s Controllers
| Hostname | Hardware | Role | Notes |
|----------|----------|------|-------|
| opi01 | Orange Pi 5 Plus | k3s controller | The thinkers |
| opi02 | Orange Pi 5 Plus | k3s controller | The thinkers |
| opi03 | Orange Pi 5 Plus | k3s controller | The thinkers |

### k3s Workers
| Hostname | Hardware | Role | Notes |
|----------|----------|------|-------|
| raccoon00-05 | Raspberry Pi 4 | k3s worker | 6x trash pandas doing actual work |

### Standalone Servers (ARM)
| Hostname | Hardware | Role | Notes |
|----------|----------|------|-------|
| eagle | Raspberry Pi 4 | Git server | Forgejo living its best life |
| mysecrets | Raspberry Pi 4 | Secrets | Where secrets hide |
| possum | Raspberry Pi 4 | NAS | The OG NAS, still kicking |

### Standalone Servers (x86)
| Hostname | Hardware | Role | Notes |
|----------|----------|------|-------|
| beacon | Acer Mini PC | Cache (aspirational) | Wannabe NixOS cache, not ready yet |
| routy | x86_64 | Router | Actually routes things |
| cardinal | x86_64 | NAS / Media | The new storage king |

### Dead but Not Forgotten
| Hostname | Hardware | Status | Notes |
|----------|----------|--------|-------|
| sparrow01-06 | Raspberry Pi 3 | RIP | The ghosts of clusters past |

**Total Active: 16 machines** (9 ARM SBCs, 3 Orange Pi 5 Plus, 3 x86 boxes, ∞ NixOS configs)

## Quick Start

```bash
# List all configured hosts
just nix-list-hosts

# Deploy to specific host
just nix-deploy raccoon00

# Deploy to all hosts (with confirmation)
just nix-deploy-all

# Build SD card image
just sd-build eagle

# Flash SD card image
just sd-flash eagle

# Format code
just format

# Lint Nix code
just lint

# Check flake validity
just nix-check

# Update flake inputs
just nix-update

# Update SOPS secrets
just sops-update
```

## Architecture Highlights

- **NixOS 25.05** with flakes (we like to live declaratively)
- **k3s** for Kubernetes (because why not)
- **SOPS** for secrets (mysecrets approves)
- **just** for automation (because it's better than make)
- **SD card images** for all the Pis (flash and forget)

## Related Projects

This project works in tandem with [home-ops](https://github.com/nrdufour/home-ops), which contains all the Kubernetes manifests and applications that run on the k3s cluster. SnowPea provides the NixOS infrastructure layer, while home-ops manages the workloads running on top of it.

**The division of labor:**
- **SnowPea** (this repo): NixOS configurations, k3s setup, hardware management, system-level services
- **home-ops**: Kubernetes manifests, Helm charts, ArgoCD applications, cluster workloads

## Goals

- [x] Produce SD card images for Raspberry Pi machines
- [x] Produce SD card images for Orange Pi 5 Plus
- [x] Master all machines in this flake
- [ ] Have fun and learn more Nix/NixOS (in progress, will never end)
- [ ] Remember which machine is which without checking the README
- [ ] Actually get beacon working as a NixOS cache

## Thanks

Inspired by and borrowed from these fine folks:
- [rjpcasalino/pie](https://github.com/rjpcasalino/pie) - General inspiration
- [bjw-s/nix-config](https://github.com/bjw-s/nix-config) - The remote-rebuild.sh script
- [truxnell/nix-config](https://github.com/truxnell/nix-config) - Amazing structure/design
- [anthr76/snowflake](https://github.com/anthr76/snowflake) - The first flake

---

*Made with declarative configuration and questionable life choices.*
