{
  description = "Flake for building Raspberry Pi based SD images and machines";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, sops-nix }@inputs:
    let
    system = "aarch64-linux";
    overlay-unstable = final: prev: {
      unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    };
    in {
      nixosConfigurations.genpi4 = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          # Overlays-module makes "pkgs.unstable" available in configuration.nix
          ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
          "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
          ./nixos/personalities/base
          ./nixos/personalities/users
        ];
      };

      nixosConfigurations.eagle = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          # Overlays-module makes "pkgs.unstable" available in configuration.nix
          ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
          "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
          ./nixos/hosts/eagle
          sops-nix.nixosModules.sops
        ];
      };

      nixosConfigurations.mysecrets = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          # Overlays-module makes "pkgs.unstable" available in configuration.nix
          ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
          "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
          ./nixos/hosts/mysecrets
          sops-nix.nixosModules.sops
        ];
      };

      # Experimental, just for one node for now

      ## Cluster Raccoon worker nodes : raspberry pi 4

      nixosConfigurations.raccoon05 = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          # Overlays-module makes "pkgs.unstable" available in configuration.nix
          ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
          "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
          ({ ... }: { networking.hostName = "raccoon05"; })
          ./nixos/hosts/k3s-rasp4-worker
          sops-nix.nixosModules.sops
        ];
      };

      ## Cluster Sparrow worker nodes : raspberry pi 3

      nixosConfigurations.sparrow01 = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          # Overlays-module makes "pkgs.unstable" available in configuration.nix
          ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
          "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
          ({ ... }: {
            networking.hostName = "sparrow01";
            # For RTL-SDR
            boot.kernelParams = [ "modprobe.blacklist=dvb_usb_rtl28xxu" ];
          })
          ./nixos/hosts/k3s-rasp3-worker
          sops-nix.nixosModules.sops
        ];
      };

      nixosConfigurations.sparrow02 = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          # Overlays-module makes "pkgs.unstable" available in configuration.nix
          ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
          "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
          ({ ... }: { networking.hostName = "sparrow02"; })
          ./nixos/hosts/k3s-rasp3-worker
          sops-nix.nixosModules.sops
        ];
      };

      nixosConfigurations.sparrow03 = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          # Overlays-module makes "pkgs.unstable" available in configuration.nix
          ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
          "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
          ({ ... }: { networking.hostName = "sparrow03"; })
          ./nixos/hosts/k3s-rasp3-worker
          sops-nix.nixosModules.sops
        ];
      };

      nixosConfigurations.sparrow04 = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          # Overlays-module makes "pkgs.unstable" available in configuration.nix
          ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
          "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
          ({ ... }: { networking.hostName = "sparrow04"; })
          ./nixos/hosts/k3s-rasp3-worker
          sops-nix.nixosModules.sops
        ];
      };

      nixosConfigurations.sparrow05 = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          # Overlays-module makes "pkgs.unstable" available in configuration.nix
          ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
          "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
          ({ ... }: {
            networking.hostName = "sparrow05";
            services.k3s.extraFlags = toString [
              "--node-label svccontroller.k3s.cattle.io/enablelb=true"
              "--node-label svccontroller.k3s.cattle.io/lbpool=external"
            ];
          })
          ./nixos/hosts/k3s-rasp3-worker
          sops-nix.nixosModules.sops
        ];
      };

      nixosConfigurations.sparrow06 = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          # Overlays-module makes "pkgs.unstable" available in configuration.nix
          ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
          "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
          ({ ... }: { networking.hostName = "sparrow06"; })
          ./nixos/hosts/k3s-rasp3-worker
          sops-nix.nixosModules.sops
        ];
      };

    };
}
