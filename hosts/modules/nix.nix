{...}: {
  config = {
    # allow unfree packages
    nixpkgs.config.allowUnfree = true;

    # enable flakes
    nix.settings.experimental-features = ["nix-command" "flakes"];

    # use nix-index to find packages for missing commands
    programs.nix-index.enable = true;
    programs.command-not-found.enable = false;
  };
}
