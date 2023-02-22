{self, ...}: {
  config = {
    # allow unfree packages
    nixpkgs.config.allowUnfree = true;

    # enable flakes
    nix.settings.experimental-features = ["nix-command" "flakes"];

    # use system nixpkgs for flake registry
    nix.registry.nixpkgs.flake = self.inputs.nixpkgs;

    # use nix-index to find packages for missing commands
    programs.nix-index.enable = true;
    programs.command-not-found.enable = false;
  };
}
