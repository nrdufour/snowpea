# Makefile to build generic pi4.img file

.PHONY: update
update:
	nix flake update

.PHONY: check
check:
	nix flake check

.PHONY: build
build:
	nix build -L .#nixosConfigurations.pi4.config.system.build.sdImage

