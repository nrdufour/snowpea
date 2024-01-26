{
  description = "Flake for building Raspberry Pi based SD images and machines";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable }:
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
          ./nixos/base
          ({ sdImage.imageName = "genpi4.img"; })
        ];
      };

      nixosConfigurations.eagle = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          # Overlays-module makes "pkgs.unstable" available in configuration.nix
          ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
          "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
          ./nixos/base
          ./nixos/apps/gitea.nix
          ({ sdImage.imageName = "eagle.img"; })
        ];
      };
    };
}
