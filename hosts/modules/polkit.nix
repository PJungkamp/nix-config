{
  self,
  system,
  ...
}: {
  config = {
    environment.systemPackages = with self.packages.${system}; [
      pks
    ];

    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (action.id == "dev.jungkamp.pkexec.pks-env") {
          return polkit.Result.AUTH_ADMIN_KEEP;
        }
      });
    '';
  };
}
