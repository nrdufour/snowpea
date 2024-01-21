# Makefile to build generic apps.img file

.PHONY: update
update:
	nix flake update

.PHONY: check
check:
	nix flake check

.PHONY: build
build:
	nix build -L .#nixosConfigurations.eagle.config.system.build.sdImage

