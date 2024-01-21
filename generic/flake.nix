{
  description = "Flake for building a Raspberry Pi SD images";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
  };

  outputs = {
    self,
    nixpkgs,
  }: rec {
    nixosConfigurations = {
      pi4 = nixpkgs.lib.nixosSystem {
        modules = [
          "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
          ../base
        ];
      };
    };

  };
}
