{
  description = "yano's NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-ros-overlay.url = "github:lopsided98/nix-ros-overlay/master";
    nixpkgs-ros.follows = "nix-ros-overlay/nixpkgs";
  };

  outputs = { self, nixpkgs, nix-ros-overlay, ... }@inputs:
    let
      system = "x86_64-linux";
      
      # 1. Create the "Safe" ROS world (using pinned nixpkgs)
      ros-pkgs = import inputs.nix-ros-overlay.inputs.nixpkgs {
        inherit system;
        overlays = [ nix-ros-overlay.overlays.default ];
      };

      # 2. Create the "Main" system world (unstable + injected ROS)
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ (final: prev: { rosPackages = ros-pkgs.rosPackages; }) ];
      };
    in {
      # This line fixes the 'nix shell' error!
      legacyPackages.${system} = pkgs;

      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
          # Inject the ROS overlay into the system configuration
          {
            nixpkgs.overlays = [ (final: prev: { rosPackages = ros-pkgs.rosPackages; }) ];
          }
        ];
      };
    };
}
