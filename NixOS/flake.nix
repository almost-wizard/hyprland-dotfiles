{
  description = "NixOS with home-manager btw";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-obsidian-old.url = "github:nixos/nixpkgs/ff06bd3398fb1bea6c937039ece7e7c8aa396ebf";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    prism-cracked.url = "github:Diegiwg/PrismLauncher-Cracked/main";

    matugen = {
      url = "github:InioX/Matugen?ref=refs/tags/v3.1.0";
    };

    hyprland.url = "github:hyprwm/Hyprland";
    
    hyprspace = {
      url = "github:KZDKM/Hyprspace";
      inputs.hyprland.follows = "hyprland";
    };

  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      nixpkgs-unstable,
      nixpkgs-obsidian-old,
      hyprland,
      hyprspace,
      ...
    }:
    let
      system = "x86_64-linux";
      unstablePkgs = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
      oldObsidianPkgs = import nixpkgs-obsidian-old {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs system hyprland hyprspace;
          pkgs-unstable = unstablePkgs;
          pkgs-obsidian-old = oldObsidianPkgs;
        };

        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            networking.hostName = "nixos";
            home-manager.extraSpecialArgs = {
              inherit hyprland hyprspace;
              pkgs-unstable = unstablePkgs;
              pkgs-obsidian-old = oldObsidianPkgs;
            };
            home-manager.users.alex = import ./home.nix;
          }
        ];
      };
    };
}
