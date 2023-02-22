{
  pkgs,
  lib,
  ...
}: {
  config = {
    # k3s server
    services.k3s = {
      enable = true;
      role = "server";
    };

    # packages installed in system profile
    environment = {
      systemPackages = with pkgs; [
        k3s
        kubernetes-helm
      ];
      variables.KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
    };

    # disable k3s on boot
    systemd.services."k3s".wantedBy = lib.mkForce [];
  };
}
