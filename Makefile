.PHONY: build

build:
	sudo nixos-rebuild switch --flake /etc/nixos#nixos

