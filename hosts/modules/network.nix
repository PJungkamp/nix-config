{
  hostName,
  pkgs,
  ...
}: {
  config = {
    # use flake hostname
    networking.hostName = hostName;

    # Enable NetworkManager
    networking.networkmanager.enable = true;

    # Enable CUPS to print documents.
    services.printing.enable = true;
    services.printing.drivers = [pkgs.hplip];

    # Enable mdns resolution and zeroconf detection
    services.avahi = {
      enable = true;
      nssmdns = true;
    };
  };
}
