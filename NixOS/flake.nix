{
  description = "NixOS with home-manager btw";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.11";

    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    prism-cracked.url = "github:Diegiwg/PrismLauncher-Cracked/main";

    matugen = {
      url = "github:InioX/Matugen?ref=refs/tags/v3.1.0";
    };

  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      nixpkgs-unstable,
      ...
    }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs system;
          pkgs-unstable = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
          };
        };

        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            networking.hostName = "nixos";
            home-manager.users.alex = import ./home.nix;
          }
        ];
      };
    };
}
