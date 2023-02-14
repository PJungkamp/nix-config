{
  config,
  lib,
  ...
}:
with lib; let
  enabled = config.boot.silent;
in {
  options = {
    boot.silent = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf enabled {
    boot = {
      initrd.verbose = false;
      consoleLogLevel = 0;
      kernelParams = [
        "quiet"
        "rd.udev.log_level=3"
        "rd.systemd.show_status=false"
        "vt.global_cursor_default=0"
      ];
    };
  };
}
