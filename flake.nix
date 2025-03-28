{
  description = "Flake for building Raspberry Pi based SD images and machines";

  inputs = {
    # Nixpkgs and unstable
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # nix-community hardware quirks
    # https://github.com/nix-community
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # nur
    nur.url = "github:nix-community/NUR";

    # sops-nix - secrets with mozilla sops
    # https://github.com/Mic92/sops-nix
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # # VSCode community extensions
    # # https://github.com/nix-community/nix-vscode-extensions
    # nix-vscode-extensions = {
    #   url = "github:nix-community/nix-vscode-extensions";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # nixos-rk3588 for Orange Pi 5 + machines
    # nixos-rk3588.url = "github:ryan4yin/nixos-rk3588";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, sops-nix, ... }@inputs:
    let
      inherit (self) outputs;
    in
    rec  {
      # extend lib with my custom functions
      lib = nixpkgs.lib.extend (
        final: prev: {
          inherit inputs;
          myLib = import ./nixos/lib { inherit inputs; lib = final; };
        }
      );

      nixosConfigurations =
        with self.lib;
        let
          specialArgs = {
            inherit inputs outputs;
          };
          # Import overlays for building nixosconfig with them.
          overlays = import ./nixos/overlays { inherit inputs; };

          # generate a base nixos configuration with the
          # specified overlays, hardware modules, and any extraModules applied
          mkNixosConfig =
            { hostname
            , system ? "x86_64-linux"
            , nixpkgs ? inputs.nixpkgs
            , hardwareModules ? [ ]
              # basemodules is the base of the entire machine building
              # here we import all the modules and setup home-manager
            , baseModules ? [
                sops-nix.nixosModules.sops
                ./nixos/profiles/global.nix # all machines get a global profile
                ./nixos/modules/nixos # all machines get nixos modules
                ./nixos/hosts/${hostname}   # load this host's config folder for machine-specific config
              ]
            , profileModules ? [ ]
            }:
            nixpkgs.lib.nixosSystem {
              inherit system lib;
              modules = baseModules ++ hardwareModules ++ profileModules;
              specialArgs = { inherit self inputs nixpkgs; };
              # Add our overlays

              pkgs = import nixpkgs {
                inherit system;
                overlays = builtins.attrValues overlays;
                config = {
                  allowUnfree = true;
                  allowUnfreePredicate = _: true;
                };
              };

            };
        in
        rec {
          # genpi4 = nixpkgs.lib.nixosSystem {
          #   inherit system;
          #   modules = [
          #     # Overlays-module makes "pkgs.unstable" available in configuration.nix
          #     ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
          #     "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
          #     ./nixos/personalities/base
          #     ./nixos/personalities/users
          #   ];
          # };

          eagle = mkNixosConfig {
            hostname = "eagle";
            system = "aarch64-linux";
            hardwareModules = [
              "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
              ./nixos/profiles/hw-rpi4.nix
            ];
            profileModules = [
              # Overlays-module makes "pkgs.unstable" available in configuration.nix
              ./nixos/profiles/role-server.nix
            ];
          };

          mysecrets = mkNixosConfig {
            hostname = "mysecrets";
            system = "aarch64-linux";
            hardwareModules = [
              "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
              ./nixos/profiles/hw-rpi4.nix
            ];
            profileModules = [
              # Overlays-module makes "pkgs.unstable" available in configuration.nix
              ./nixos/profiles/role-server.nix
            ];
          };

          possum = mkNixosConfig {
            hostname = "possum";
            system = "aarch64-linux";
            hardwareModules = [
              "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
              ./nixos/profiles/hw-rpi4.nix
            ];
            profileModules = [
              # Overlays-module makes "pkgs.unstable" available in configuration.nix
              ./nixos/profiles/role-server.nix
            ];
          };

          ### CLUSTER k3s

          ## Cluster Raccoon controller nodes : raspberry pi 4

          raccoon00 = mkNixosConfig {
            hostname = "raccoon00";
            system = "aarch64-linux";
            hardwareModules = [
              "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
              ./nixos/profiles/hw-rpi4.nix
            ];
            profileModules = [
              # Overlays-module makes "pkgs.unstable" available in configuration.nix
              ./nixos/profiles/role-server.nix
              ./nixos/profiles/role-k3s-worker.nix
            ];
          };

          raccoon01 = mkNixosConfig {
            hostname = "raccoon01";
            system = "aarch64-linux";
            hardwareModules = [
              "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
              ./nixos/profiles/hw-rpi4.nix
            ];
            profileModules = [
              # Overlays-module makes "pkgs.unstable" available in configuration.nix
              ./nixos/profiles/role-server.nix
              ./nixos/profiles/role-k3s-worker.nix
            ];
          };

          raccoon02 = mkNixosConfig {
            hostname = "raccoon02";
            system = "aarch64-linux";
            hardwareModules = [
              "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
              ./nixos/profiles/hw-rpi4.nix
            ];
            profileModules = [
              # Overlays-module makes "pkgs.unstable" available in configuration.nix
              ./nixos/profiles/role-server.nix
              ./nixos/profiles/role-k3s-worker.nix
            ];
          };

          ## Cluster Raccoon worker nodes : raspberry pi 4

          raccoon03 = mkNixosConfig {
            hostname = "raccoon03";
            system = "aarch64-linux";
            hardwareModules = [
              "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
              ./nixos/profiles/hw-rpi4.nix
            ];
            profileModules = [
              # Overlays-module makes "pkgs.unstable" available in configuration.nix
              ./nixos/profiles/role-server.nix
              ./nixos/profiles/role-k3s-worker.nix
            ];
          };

          raccoon04 = mkNixosConfig {
            hostname = "raccoon04";
            system = "aarch64-linux";
            hardwareModules = [
              "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
              ./nixos/profiles/hw-rpi4.nix
            ];
            profileModules = [
              # Overlays-module makes "pkgs.unstable" available in configuration.nix
              ./nixos/profiles/role-server.nix
              ./nixos/profiles/role-k3s-worker.nix
            ];
          };

          raccoon05 = mkNixosConfig {
            hostname = "raccoon05";
            system = "aarch64-linux";
            hardwareModules = [
              "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
              ./nixos/profiles/hw-rpi4.nix
            ];
            profileModules = [
              # Overlays-module makes "pkgs.unstable" available in configuration.nix
              ./nixos/profiles/role-server.nix
              ./nixos/profiles/role-k3s-worker.nix
            ];
          };

          ## Sparrow nodes : raspberry pi 3 -- not in cluster

          # sparrow01 = mkNixosConfig {
          #   hostname = "sparrow01";
          #   system = "aarch64-linux";
          #   hardwareModules = [
          #     "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
          #     ./nixos/profiles/hw-rpi3.nix
          #   ];
          #   profileModules = [
          #     # Overlays-module makes "pkgs.unstable" available in configuration.nix
          #     ./nixos/profiles/role-server.nix
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

          opi01 = mkNixosConfig {
            hostname = "opi01";
            system = "aarch64-linux";
            hardwareModules = [
              ./nixos/profiles/hw-orangepi5plus.nix
            ];
            profileModules = [
              # Overlays-module makes "pkgs.unstable" available in configuration.nix
              ./nixos/profiles/role-server.nix
              ./nixos/profiles/role-k3s-controller.nix
            ];
          };

          opi02 = mkNixosConfig {
            hostname = "opi02";
            system = "aarch64-linux";
            hardwareModules = [
              ./nixos/profiles/hw-orangepi5plus.nix
            ];
            profileModules = [
              # Overlays-module makes "pkgs.unstable" available in configuration.nix
              ./nixos/profiles/role-server.nix
              ./nixos/profiles/role-k3s-controller.nix
            ];
          };

          opi03 = mkNixosConfig {
            hostname = "opi03";
            system = "aarch64-linux";
            hardwareModules = [
              ./nixos/profiles/hw-orangepi5plus.nix
            ];
            profileModules = [
              # Overlays-module makes "pkgs.unstable" available in configuration.nix
              ./nixos/profiles/role-server.nix
              ./nixos/profiles/role-k3s-controller.nix
            ];
          };

          ###

          beacon = mkNixosConfig {
            hostname = "beacon";
            system = "x86_64-linux";
            hardwareModules = [
              ./nixos/profiles/hw-acer-minipc.nix
            ];
            profileModules = [
              # Overlays-module makes "pkgs.unstable" available in configuration.nix
              ./nixos/profiles/role-server.nix
            ];
          };

      };

      # Convenience output that aggregates the outputs for home, nixos.
      # Also used in ci to build targets generally.
      top =
        let
          nixtop = nixpkgs.lib.genAttrs
            (builtins.attrNames inputs.self.nixosConfigurations)
            (attr: inputs.self.nixosConfigurations.${attr}.config.system.build.toplevel);
        in
        nixtop;

    };
}
