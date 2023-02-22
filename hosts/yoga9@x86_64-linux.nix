{
  lib,
  pkgs,
  self,
  system,
  hostName,
  ...
}: {
  imports = with self.nixosModules; [
    ./modules/base.nix
    ./modules/bluetooth.nix
    ./modules/dev.nix
    ./modules/graphical.nix
    ./modules/i18n.nix
    ./modules/keymap.nix
    ./modules/network.nix
    ./modules/nix.nix
    ./modules/pipewire.nix
    ./modules/plymouth.nix
    ./modules/sogno.nix
    ./modules/systemd-boot.nix
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
      extraGroups = ["networkmanager" "wheel" "docker" "wireshark"];
    };

    # force suspend-then-hibernate.
    systemd.targets."suspend-then-hibernate".aliases = ["suspend.target"];

    # my time zone.
    time.timeZone = "Europe/Berlin";

    programs.wireshark.enable = true;

    # enable the OpenSSH daemon
    # services.openssh.enable = true;

    # disable firewall
    networking.firewall.enable = false;

    boot = rec {
      initrd.availableKernelModules = ["xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod"];
      extraModulePackages = with self.packages.${system}; [(ideapad-wmi-usage-mode.override {kernel = kernelPackages.kernel;})];
      kernelModules = ["kvm-intel" "ideapad-wmi-usage-mode"];
      loader.efi.efiSysMountPoint = "/boot/efi";
      kernelPackages = pkgs.linuxPackages_latest;
      # resume from swapfile
      resumeDevice = "/dev/disk/by-uuid/ceb53129-af82-49a7-8e6e-727617ad0e55";
      kernelParams = ["iwlwifi.power_save=1" "resume_offset=37664768"];
    };

    # basic filesystems
    fileSystems = {
      "/" = {
        device = "/dev/disk/by-uuid/ceb53129-af82-49a7-8e6e-727617ad0e55";
        fsType = "ext4";
      };
      "/boot/efi" = {
        device = "/dev/disk/by-uuid/247B-CC47";
        fsType = "vfat";
      };
    };

    # 16GB swapfile
    swapDevices = [
      {
        device = "/swapfile";
        size = 16 * 1024;
      }
    ];

    zramSwap.enable = true;

    services = {
      # regulary trim for SSD health
      fstrim.enable = true;
      # Intel Thermald cooling daemon
      thermald.enable = true;
      # TLP power saving daemon
      power-profiles-daemon.enable = false;
      tlp = {
        enable = true;
        settings = {
          # networking
          RESTORE_DEVICE_STATE_ON_STARTUP = 1;
          DEVICES_TO_DISABLE_ON_LAN_CONNECT = "wifi";
          DEVICES_TO_ENABLE_ON_LAN_DISCONNECT = "wifi";
          # CPU
          CPU_ENERGY_PERF_POLICY_ON_AC = "default";
          CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
          CPU_HWP_DYNAMIC_BOOST_ON_AC = 1;
          CPU_HWP_DYNAMIC_BOOST_ON_BAT = 1;
          CPU_MAX_PERF_ON_AC = 100;
          CPU_MIN_PERF_ON_AC = 0;
          CPU_MAX_PERF_ON_BAT = 30;
          CPU_MIN_PERF_ON_BAT = 0;
          # platform profile
          PLATFORM_PROFILE_ON_AC = "balanced";
          PLATFORM_PROFILE_ON_BAT = "low-power";
          # PCIe ASPM
          PCIE_ASPM_ON_AC = "performance";
          PCIE_ASPM_ON_BAT = "powersupersave";
        };
      };
    };

    hardware = {
      cpu.intel.updateMicrocode = true;
      enableRedistributableFirmware = true; # WiFi firmware
    };
  };
}
