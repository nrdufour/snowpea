# Makefile to build generic img files
# and make sure the flake is happy

.PHONY: update
update:
	nix flake update

.PHONY: check
check:
	nix flake check

.PHONY: build_genpi4
build_genpi4:
	nix build -L .#nixosConfigurations.genpi4.config.system.build.sdImage

.PHONY: build_eagle
build_eagle:
	nix build -L .#nixosConfigurations.eagle.config.system.build.sdImage

.PHONY: build_mysecrets
build_mysecrets:
	nix build -L .#nixosConfigurations.mysecrets.config.system.build.sdImage
