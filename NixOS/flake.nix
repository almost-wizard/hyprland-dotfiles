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

    # v0.55 switched the default configuration language from hyprlang (.conf)
    # to Lua. Keep the last hyprlang release until the existing dotfiles have
    # been migrated.
    hyprland.url = "github:hyprwm/Hyprland/v0.54.3";

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
              inherit hyprland;
              pkgs-unstable = unstablePkgs;
            };
            home-manager.users.alex = import ./home.nix;
          }
        ];
      };
    };
}
