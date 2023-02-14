{
  lib,
  pkgs,
  self,
  hostName,
  ...
}: let
  defaultStopped = {wantedBy = lib.mkForce [];};
  bluezWithExperimental = pkgs.bluez.override {withExperimental = true;};
in {
  imports = with self.nixosModules; [
    hardware-yoga9
    silent-boot
  ];

  config = {
    # don't change after system setup!
    system.stateVersion = "22.11";

    # setup user
    users.users.pjungkamp = {
      uid = 1000;
      isNormalUser = true;
      description = "Philipp Jungkamp";
      home = "/home/pjungkamp";
      extraGroups = ["networkmanager" "wheel" "docker"];
    };

    # force suspend-then-hibernate
    systemd.targets."suspend-then-hibernate".aliases = ["suspend.target"];

    # Set your time zone.
    time.timeZone = "Europe/Berlin";

    # Select internationalisation properties.
    i18n = {
      defaultLocale = "en_US.UTF-8";
      extraLocaleSettings = {
        LC_ADDRESS = "de_DE.UTF-8";
        LC_IDENTIFICATION = "de_DE.UTF-8";
        LC_MEASUREMENT = "de_DE.UTF-8";
        LC_MONETARY = "de_DE.UTF-8";
        LC_NAME = "de_DE.UTF-8";
        LC_NUMERIC = "de_DE.UTF-8";
        LC_PAPER = "de_DE.UTF-8";
        LC_TELEPHONE = "de_DE.UTF-8";
        LC_TIME = "de_DE.UTF-8";
      };
    };

    # plymouth boot splash
    boot = {
      plymouth.enable = true;
      silent = true;
    };

    # systemd-boot config
    boot.loader = {
      systemd-boot.enable = true;
      systemd-boot.configurationLimit = 12;
      timeout = 0; # menu-hidden
      efi.canTouchEfiVariables = true;
    };

    # add experimental settings for bluetooth battery status
    hardware.bluetooth = {
      package = bluezWithExperimental;
      settings = {
        General.Experimental = true;
      };
    };

    # use xkb keymap for console
    console.useXkbConfig = true;

    services.xserver = {
      # Enable the graphical environment
      enable = true;

      # Configure keymap
      layout = "us";
      xkbVariant = "altgr-intl";

      # Enable the GNOME Desktop Environment.
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };

    # use flake hostname
    networking.hostName = hostName;

    # Enable NetworkManager
    networking.networkmanager.enable = true;

    # Enable CUPS to print documents.
    services.printing.enable = true;

    # Enable mdns resolution and zeroconf detection
    services.avahi = {
      enable = true;
      nssmdns = true;
    };

    # k3s server
    services.k3s = {
      enable = true;
      role = "server";
    };
    systemd.services."k3s" = defaultStopped;

    # docker daemon
    virtualisation.docker.enable = true;
    systemd.services."docker" = defaultStopped;

    # Enable sound with pipewire.
    sound.enable = true;
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # allow unfree packages
    nixpkgs.config.allowUnfree = true;

    # enable flakes
    nix.settings.experimental-features = ["nix-command" "flakes"];

    # packages installed in system profile
    environment.systemPackages = with pkgs; [
      blackbox-terminal
      kakoune
      k3s
      kubernetes-helm
    ];

    environment.variables = with pkgs; {
      EDITOR = "kak";
      KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
      NIXOS_OZONE_WL = "1";
    };

    fonts = {
      enableDefaultFonts = true;

      # download only Iosevka
      fonts = with pkgs; [
        (nerdfonts.override {fonts = ["Iosevka"];})
      ];

      # use Iosevka Term by default
      fontconfig.defaultFonts.monospace = ["Iosevka Nerd Font Mono"];
    };

    # install fish shell
    programs.fish.enable = true;

    # use nix-index to find packages for missing commands
    programs.nix-index.enable = true;
    programs.command-not-found.enable = false;

    # Enable the OpenSSH daemon.
    # services.openssh.enable = true;

    # Disable Firewall
    networking.firewall.enable = false;
  };
}
