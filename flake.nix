{
  description = "A very basic flake";

  inputs = {
    # system configuration
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # home-manager configuration
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager }@inputs:
  let
    # helper for building my configurations
    util = import ./util.nix { inherit nixpkgs home-manager; };
    # load home-manager modules from ./users/
    userModules = util.mkUserModules [ "pjungkamp@yoga9" ];
    # load nixos modules from ./hosts/
    hostModules = util.mkHostModules [ "yoga9@x86_64-linux" ];
  in {
    homeConfigurations = util.mkHomeConfigurations { inherit userModules inputs; };
    nixosConfigurations = util.mkNixosConfigurations { inherit userModules hostModules inputs; };
  };
}
