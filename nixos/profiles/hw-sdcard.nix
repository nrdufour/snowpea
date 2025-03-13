{
  config,
  nixpkgs,
  ...
}:
{
  imports = [
    "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
  ];

  sdImage.imageName = "${config.networking.hostName}.img";
}