{
  config,
  lib,
  ...
}:
with lib; let
  inherit (builtins) hasAttr;

  cfg = config.programs.gnome-shell-extensions;

  extensionPackage = with types;
    package
    // {
      check = x: isDerivation x && hasAttr "extensionUuid" x;
    };
in {
  options.programs.gnome-shell-extensions = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "enable GNOME Shell Extensions";
    };

    extensions = mkOption {
      type = types.listOf extensionPackage;
      default = [];
      example = literalExpression ''
        [
          pkgs.gnomeExtensions.blur-my-shell
        ]
      '';
    };
  };

  config = {
    home.packages = optionals cfg.enable cfg.extensions;
    dconf.settings = {
      "org/gnome/shell".enabled-extensions = map (extension: extension.extensionUuid) (optionals cfg.enable cfg.extensions);
    };
  };
}
