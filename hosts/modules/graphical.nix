{pkgs, ...}:
# Configure the graphical environment
{
  config = {
    services.xserver = {
      enable = true;

      # Enable the GNOME Desktop Environment.
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };

    qt = {
      enable = true;
      platformTheme = "gnome";
      style = "adwaita-dark";
    };

    environment = {
      systemPackages = with pkgs; [
        blackbox-terminal
        rnote
        wl-clipboard
      ];
      variables.NIXOS_OZONE_WL = "1";
    };

    fonts = {
      enableDefaultFonts = true;

      # download only Iosevka
      fonts = with pkgs; [
        (nerdfonts.override {fonts = ["Iosevka"];})
        dejavu_fonts
        ipafont
      ];

      # use Iosevka Term by default
      fontconfig.defaultFonts = {
        monospace = [
          "Iosevka Nerd Font Mono"
          "IPAGothic"
        ];
        sansSerif = [
          "DejaVu Sans"
          "IPAPGothic"
        ];
        serif = [
          "DejaVu Serif"
          "IPAPMincho"
        ];
      };
    };

    i18n.inputMethod = {
      enabled = "ibus";
      ibus.engines = with pkgs.ibus-engines; [anthy];
    };
  };
}
