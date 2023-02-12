{ ... }:
{
  config = {
    boot.plymouth.enable = true;
    boot.initrd.verbose = false;
    boot.consoleLogLevel = 0;
    boot.kernelParams = [
      "quiet"
      "rd.udev.log_level=3"
      "rd.systemd.show_status=false"
      "vt.global_cursor_default=0"
    ];
  };
}