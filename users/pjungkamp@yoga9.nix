{ config, pkgs, ... }:
let
  userName = config.home.username;
  myVscode = pkgs.vscode.override { commandLineArgs = "--touch-events="; };
in {
  config = {
    home.packages = with pkgs; [
      blackbox-terminal
      adw-gtk3
      wireshark
      evolution
      spotify
    ];

    programs.home-manager.enable = true;
    programs.firefox.enable = true;
    programs.bottom.enable = true;

    dconf = {
      enable = true;
      settings = {
        "org/gnome/settings-daemon/plugins/media-keys" = {
          # remove the static binding preventing users from remapping the calculator key
          calculator-static = [ "" ];
          custom-keybindings = [
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/terminal/"
          ];
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/terminal" = {
          binding = "XF86Calculator";
          command = "blackbox";
          name = "Open Terminal";
        };
      };
    };

    programs.ssh = {
      enable = true;
    };

    programs.git = {
      enable = true;
      userName = "Philipp Jungkamp";
      userEmail = "p.jungkamp@gmx.net";
    };

    programs.vscode = {
      enable = true;
      package = myVscode;
    };

    programs.kakoune = {
      enable = true;
      config = {
        ui = {
          setTitle = true;
          assistant = "none";
          enableMouse = true;
        };
        wrapLines.enable = true;
        numberLines = {
          enable = true;
          relative = true;
        };
      };
    };

    programs.starship = {
      enable = true;
      settings = {
        battery.disabled = true;
        shell = {
          disabled = false;
          format = "[$indicator]($style)";
          fish_indicator = "";
          bash_indicator = "bash ";
        };
      };
    };

    programs.fish = {
      enable = true;
      shellInit = ''
        # fish configuration
        set fish_greeting ""
      '';
      functions = {
        exit = ''
          test "$(count $argv)" = 0
          and builtin exit 0
          or builtin exit $argv
        '';
      };
      shellAbbrs = {
        c = "clear";
        e = "exit";
        ga = "git add";
        gc = "git commit";
        gs = "git status";
      };
    };

    programs.bash = {
      enable = true;
      initExtra = ''
        # PATH of parent process
        PPATH="$(
          cat /proc/$PPID/environ | while IFS= read -d ''' ENV ; do
            [[ "$ENV" == PATH=* ]] && printf %s "''${ENV#PATH=}"
          done
        )"

        # switch to fish in interactive shell when either
        # - the parent is not fish
        # - the parent is fish but of a different user
        # - the parent is fish but with a different PATH
        #
        # the different user covers the sudo/pkexec case
        #
        # the PATH can be used to check whether we entered a
        # nix shell environment where I'd prefer my shell to
        # be fish
        if [[ ! "$(ps -q $PPID -o comm=)" = fish ]] \
        || [[ ! "$(ps -q $PPID -o user=)" = "$(whoami)" ]] \
        || [[ ! "$PPATH" = "$PATH" ]]
        then exec fish; fi

        # silent exit command
        exit() { builtin exit $@ 2>/dev/null; }
      '';
    };
  };
}