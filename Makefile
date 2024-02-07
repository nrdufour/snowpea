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

.PHONY: build_myca
build_myca:
	nix build -L .#nixosConfigurations.myca.config.system.build.sdImage
