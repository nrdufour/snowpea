{
  description = "Flake for building Raspberry Pi based SD images and machines";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
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
    in
    {
      nixosConfigurations = {
        genpi4 = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            # Overlays-module makes "pkgs.unstable" available in configuration.nix
            ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
            "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
            ./nixos/personalities/base
            ./nixos/personalities/users
          ];
        };

        eagle = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            # Overlays-module makes "pkgs.unstable" available in configuration.nix
            ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
            "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
            ./nixos/hosts/eagle
            sops-nix.nixosModules.sops
          ];
        };

        mysecrets = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            # Overlays-module makes "pkgs.unstable" available in configuration.nix
            ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
            "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
            ./nixos/hosts/mysecrets
            sops-nix.nixosModules.sops
          ];
        };

        ### CLUSTER k3s

        ## Cluster Raccoon controller nodes : raspberry pi 4

        raccoon01 = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            # Overlays-module makes "pkgs.unstable" available in configuration.nix
            ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
            "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
            (_: { networking.hostName = "raccoon01"; })
            ./nixos/hosts/k3s-rasp4-controller
            sops-nix.nixosModules.sops
          ];
        };

        raccoon02 = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            # Overlays-module makes "pkgs.unstable" available in configuration.nix
            ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
            "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
            (_: { networking.hostName = "raccoon02"; })
            ./nixos/hosts/k3s-rasp4-controller
            sops-nix.nixosModules.sops
          ];
        };

        ## Cluster Raccoon worker nodes : raspberry pi 4

        raccoon03 = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            # Overlays-module makes "pkgs.unstable" available in configuration.nix
            ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
            "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
            (_: { networking.hostName = "raccoon03"; })
            ./nixos/hosts/k3s-rasp4-worker
            sops-nix.nixosModules.sops
          ];
        };

        raccoon04 = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            # Overlays-module makes "pkgs.unstable" available in configuration.nix
            ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
            "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
            (_: {
              networking.hostName = "raccoon04";
              services.k3s.extraFlags = toString [
                "--node-label svccontroller.k3s.cattle.io/enablelb=true"
                "--node-label svccontroller.k3s.cattle.io/lbpool=internal"
              ];
            })
            ./nixos/hosts/k3s-rasp4-worker
            sops-nix.nixosModules.sops
          ];
        };

        raccoon05 = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            # Overlays-module makes "pkgs.unstable" available in configuration.nix
            ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
            "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
            (_: { networking.hostName = "raccoon05"; })
            ./nixos/hosts/k3s-rasp4-worker
            sops-nix.nixosModules.sops
          ];
        };

        ## Cluster Sparrow worker nodes : raspberry pi 3

        # sparrow01 = nixpkgs.lib.nixosSystem {
        #   inherit system;
        #   modules = [
        #     # Overlays-module makes "pkgs.unstable" available in configuration.nix
        #     ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
        #     "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
        #     (_: {
        #       networking.hostName = "sparrow01";
        #       # For RTL-SDR
        #       boot.kernelParams = [ "modprobe.blacklist=dvb_usb_rtl28xxu" ];
        #     })
        #     ./nixos/hosts/k3s-rasp3-worker
        #     sops-nix.nixosModules.sops
        #   ];
        # };

        # sparrow02 = nixpkgs.lib.nixosSystem {
        #   inherit system;
        #   modules = [
        #     # Overlays-module makes "pkgs.unstable" available in configuration.nix
        #     ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
        #     "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
        #     (_: { networking.hostName = "sparrow02"; })
        #     ./nixos/hosts/k3s-rasp3-worker
        #     sops-nix.nixosModules.sops
        #   ];
        # };

        # sparrow03 = nixpkgs.lib.nixosSystem {
        #   inherit system;
        #   modules = [
        #     # Overlays-module makes "pkgs.unstable" available in configuration.nix
        #     ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
        #     "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
        #     (_: { networking.hostName = "sparrow03"; })
        #     ./nixos/hosts/k3s-rasp3-worker
        #     sops-nix.nixosModules.sops
        #   ];
        # };

        # sparrow04 = nixpkgs.lib.nixosSystem {
        #   inherit system;
        #   modules = [
        #     # Overlays-module makes "pkgs.unstable" available in configuration.nix
        #     ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
        #     "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
        #     (_: { networking.hostName = "sparrow04"; })
        #     ./nixos/hosts/k3s-rasp3-worker
        #     sops-nix.nixosModules.sops
        #   ];
        # };

        # sparrow05 = nixpkgs.lib.nixosSystem {
        #   inherit system;
        #   modules = [
        #     # Overlays-module makes "pkgs.unstable" available in configuration.nix
        #     ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
        #     "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
        #     (_: {
        #       networking.hostName = "sparrow05";
        #       services.k3s.extraFlags = toString [
        #         "--node-label svccontroller.k3s.cattle.io/enablelb=true"
        #         "--node-label svccontroller.k3s.cattle.io/lbpool=external"
        #       ];
        #     })
        #     ./nixos/hosts/k3s-rasp3-worker
        #     sops-nix.nixosModules.sops
        #   ];
        # };

        ## Decommissioned for now ...
        # sparrow06 = nixpkgs.lib.nixosSystem {
        #   inherit system;
        #   modules = [
        #     # Overlays-module makes "pkgs.unstable" available in configuration.nix
        #     ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
        #     "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
        #     (_: { networking.hostName = "sparrow06"; })
        #     ./nixos/hosts/k3s-rasp3-worker
        #     sops-nix.nixosModules.sops
        #   ];
        # };
      };

    };
}
