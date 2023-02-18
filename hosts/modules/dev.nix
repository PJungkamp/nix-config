{pkgs, ...}: {
  config = {
    # docker daemon
    virtualisation.docker.enable = true;
    systemd.services."docker".wantedBy = [];

    # packages installed in system profile
    environment.systemPackages = with pkgs; [
      watchexec
    ];
  };
}
