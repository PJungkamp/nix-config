{hostName, ...}: {
  # use flake hostname
  networking.hostName = hostName;

  # Enable NetworkManager
  networking.networkmanager.enable = true;
}
