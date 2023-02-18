{...}:
# Configure keymap
{
  config = {
    # use xkb keymap for console
    console.useXkbConfig = true;
    # set xkb keymap
    services.xserver = {
      layout = "us";
      xkbVariant = "altgr-intl";
    };
  };
}
