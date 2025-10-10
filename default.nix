{ pkgs ? import <nixpkgs> { } }:
pkgs.mkShell {
  # nativeBuildInputs is usually what you want -- tools you need to run
  nativeBuildInputs = with pkgs.buildPackages; [
    go-task
    jq
    statix
    nixpkgs-fmt
    nixos-rebuild
  ];
}
