{ pkgs ? import <nixpkgs> { } }:
pkgs.mkShell {
  # nativeBuildInputs is usually what you want -- tools you need to run
  nativeBuildInputs = with pkgs.buildPackages; [
    jq
    statix
    nixpkgs-fmt
    nixos-rebuild
    just
  ];
}
