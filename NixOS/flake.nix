{
  description = "NixOS with home-manager btw";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    matugen = {
      url = "github:InioX/Matugen?ref=refs/tags/v3.1.0";
    };

    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hyprland updated to latest version (v0.55+ with Lua configuration)
    hyprland.url = "github:hyprwm/Hyprland";

    quickshell-overview = {
      url = "github:Shanu-Kumawat/quickshell-overview";
      flake = false;
    };

  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      nixpkgs-unstable,
      antigravity-nix,
      hyprland,
      ...
    }:
    let
      system = "x86_64-linux";
      unstablePkgs = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs system hyprland;
          pkgs-unstable = unstablePkgs;
        };

        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            networking.hostName = "nixos";
            home-manager.extraSpecialArgs = {
              inherit inputs hyprland;
              pkgs-unstable = unstablePkgs;
            };
            home-manager.users.alex = import ./home.nix;
          }
        ];
      };
    };
}
