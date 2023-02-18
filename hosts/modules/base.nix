{pkgs, ...}: {
  config = {
    environment = {
      systemPackages = with pkgs; [
        lm_sensors
        kakoune
        ripgrep
        jq
        bottom
        procs
        wget
        curl
        qpdf
      ];

      variables = {
        VISUAL = "kak";
      };
    };

    # install fish shell
    programs.fish.enable = true;
  };
}
