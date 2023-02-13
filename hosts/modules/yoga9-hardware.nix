{
  config,
  pkgs,
  ...
}: {
  config = {
    # initrd basic settings
    boot.initrd.availableKernelModules = ["xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod"];
    boot.kernelModules = ["kvm-intel" "i915"];

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
    boot.loader.efi.efiSysMountPoint = "/boot/efi";

    # use latest kernel for device drivers
    boot.kernelPackages = pkgs.linuxPackages_latest;

    # 16GB swapfile
    swapDevices = [
      {
        device = "/swapfile";
        size = 16 * 1024;
      }
    ];

    # resume from swap
    boot.resumeDevice = "/dev/disk/by-uuid/ceb53129-af82-49a7-8e6e-727617ad0e55";
    boot.kernelParams = ["resume_offset=37664768"];

    # regulary trim for SSD health
    services.fstrim.enable = true;

    # Intel Thermald cooling daemon
    services.thermald.enable = true;

    # TLP power saving daemon
    services.power-profiles-daemon.enable = false;
    services.tlp = {
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
      };
    };

    # microcode updates
    hardware.cpu.intel.updateMicrocode = true;
    hardware.enableRedistributableFirmware = true;
  };
}
