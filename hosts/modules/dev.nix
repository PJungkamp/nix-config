{
  pkgs,
  lib,
  ...
}: {
  config = {
    # docker daemon
    virtualisation.docker = {
      enable = true;
      enableOnBoot = false;
    };

    # packages installed in system profile
    environment.systemPackages = with pkgs; [
      watchexec
      docker-credential-helpers
    ];
  };
}
