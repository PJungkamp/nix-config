{hostName, ...}: {
  config = {
    boot = {
      plymouth.enable = true;
      initrd.verbose = false;
      consoleLogLevel = 0;
      kernelModules =
        {
          yoga9 = ["i915"];
        }
        .${hostName}
        or [];
      kernelParams = [
        "quiet"
        "rd.udev.log_level=3"
        "rd.systemd.show_status=false"
        "vt.global_cursor_default=0"
      ];
    };
  };
}
