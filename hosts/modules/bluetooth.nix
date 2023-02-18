{pkgs, ...}:
# add experimental settings for bluetooth battery status
let
  bluezWithExperimental = pkgs.bluez.override {withExperimental = true;};
in {
  config = {
    hardware.bluetooth = {
      enable = true;
      package = bluezWithExperimental;
      settings = {
        General.Experimental = true;
      };
    };
  };
}
