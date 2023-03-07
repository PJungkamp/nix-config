{
  lib,
  config,
  self,
  system,
  ...
}:
with lib; let
  cfg = config.programs.sciebo-client;
  pkg = self.packages.${system}.sciebo-client;
in {
  options = {
    programs.sciebo-client.enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = {
    environment.systemPackages = mkIf cfg.enable [pkg];
    environment.etc = mkIf cfg.enable {
      "sciebo/sync-exclude.lst".source = "${pkg}/etc/sciebo/sync-exclude.lst";
    };
  };
}
