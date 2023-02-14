{
  description = "A very basic flake";

  inputs = {
    # system configuration
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # home-manager configuration
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    # helper for building my configurations
    util = import ./util.nix {inherit nixpkgs home-manager;};
    # make home-manager modules from ./users/
    userModules = util.mkUserModules [
      "pjungkamp@yoga9"
    ];
    # make nixos modules from ./hosts/
    hostModules = util.mkHostModules [
      "yoga9@x86_64-linux"
    ];
    # make home-manager modules from ./hostModules/
    homeModules = util.mkHomeModules [
      "gnome-settings-daemon"
      "gnome-shell-extensions"
    ];
    # make home-manager modules from ./nixosModules/
    nixosModules =
      util.mkNixosModules [
      ];
    # format code using alejandra
    formatter = {
      x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
    };
    # make standalone homeConfigurations
    homeConfigurations = util.mkHomeConfigurations {inherit userModules inputs;};
    # make nixosConfigurations with included home-manager
    nixosConfigurations = util.mkNixosConfigurations {inherit userModules hostModules inputs;};
  in {
    inherit
      homeConfigurations
      nixosConfigurations
      formatter
      nixosModules
      homeModules
      ;
  };
}
