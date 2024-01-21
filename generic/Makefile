
## Ref
## sudo nixos-rebuild test -I nixos-config=./configuration.nix

.PHONY: update
update:
	nix flake update

.PHONY: check
check:
	nix flake check

.PHONY: build
build:
	nix build -L .#nixosConfigurations.pi4.config.system.build.sdImage

