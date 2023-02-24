{
  config,
  pkgs,
  self,
  ...
}: let
  userName = config.home.username;
  myVscode = pkgs.vscode.override {commandLineArgs = "--touch-events=";};
in {
  imports = with self.homeModules; [
    gnome-settings-daemon
    gnome-shell-extensions
  ];
  config = {
    home.packages = with pkgs; [
      (writeShellScriptBin
        "gnome-terminal"
        ''
          set -- "''${@:2}"
          ARGS="''${@@Q}"
          exec ${lib.meta.getExe blackbox-terminal} -c "''${ARGS}"
        '')
      adw-gtk3
      wireshark
      evolution
    ];

    programs.home-manager.enable = true;
    programs.firefox.enable = true;
    programs.bottom.enable = true;

    services.gnome-keyring.enable = true;

    xdg.configFile = {
      "docker/config.json".text = builtins.toJSON {
        credsStore = "secretservice";
      };
    };

    dconf = {
      enable = true;
      settings = {
        "org/gnome/shell/extensions/battery-indicator-icon" = {
          status-style = "circle";
          show-icon-text = 0;
        };
        "org/gnome/shell/extensions/quick-settings-tweaks" = {
          volume-mixer-enabled = false;
          notifications-enabled = false;
          add-dnd-quick-toggle-enabled = false;
          media-control-compact-mode = false;
        };
      };
    };

    programs.gnome-shell-extensions = {
      enable = true;
      extensions = with pkgs.gnomeExtensions; [
        gsconnect
        battery-indicator-icon
        quick-settings-tweaker
        bluetooth-quick-connect
      ];
    };

    programs.gnome-settings-daemon.plugins.media-keys = {
      overrideStatic = true;
      customBindings = with pkgs; let
        inherit (lib.meta) getExe;
      in {
        terminal = {
          name = "Open Terminal";
          binding = "XF86Calculator";
          command = "${getExe blackbox-terminal}";
        };
        bottom = {
          name = "Open Process Viewer";
          binding = "XF86Launch4";
          command = "${getExe blackbox-terminal} -c ${getExe bottom}";
        };
        pavucontrol = {
          name = "Open Sound Mixer";
          binding = "XF86Launch2";
          command = "${getExe pavucontrol}";
        };
        firefox = {
          name = "Open Firefox";
          binding = "Favorites";
          command = "${getExe firefox}";
        };
      };
    };

    programs.ssh = {
      enable = true;
      forwardAgent = true;
      matchBlocks = {
        "rasppi" = {
          hostname = "mg6mep16gbupru0w.myfritz.net";
          user = "pjungkamp";
          port = 26839;
        };
      };
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
        set fish_greeting ""
        set fish_key_bindings fish_vi_key_bindings
      '';
      shellAbbrs = {
        e = "exit 0";
        exit = "exit 0";
        c = "clear";
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
          cat 2>/dev/null /proc/$PPID/environ | while IFS= read -d ''' ENV ; do
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
