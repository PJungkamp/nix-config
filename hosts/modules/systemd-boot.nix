{...}: {
  config = {
    # EFI boot configuration
    boot.loader = {
      systemd-boot.enable = true;
      systemd-boot.configurationLimit = 12;
      timeout = 0; # menu-hidden
      efi.canTouchEfiVariables = true;
    };
  };
}
