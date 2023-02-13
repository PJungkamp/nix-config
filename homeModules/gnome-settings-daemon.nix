{
  config,
  lib,
  ...
}:
with lib; let
  inherit (attrsets) nameValuePair;
  inherit (builtins) listToAttrs attrNames attrValues elem filter;

  attrsToList = attrset:
    map
    (name: {
      inherit name;
      value = getAttr name attrset;
    })
    (attrNames attrset);

  # all static keys spcified in the org.gnome.settings-daemon.plugins.media-keys schema
  #
  # ```bash
  # SCHEMA=org.gnome.settings-daemon.plugins.media-keys
  # for KEY in $(gsettings list-keys $SCHEMA | grep -e '-static$') ; do
  #   echo "$KEY = $(gsettings get $SCHEMA $KEY | sed -e 's|\'|"|g' -e 's|,||g');"
  # done
  # ```
  staticKeys = {
    battery-status-static = ["XF86Battery"];
    calculator-static = ["XF86Calculator"];
    control-center-static = ["XF86Tools"];
    eject-static = ["XF86Eject"];
    email-static = ["XF86Mail"];
    hibernate-static = ["XF86Suspend" "XF86Hibernate"];
    home-static = ["XF86Explorer"];
    keyboard-brightness-down-static = ["XF86KbdBrightnessDown"];
    keyboard-brightness-toggle-static = ["XF86KbdLightOnOff"];
    keyboard-brightness-up-static = ["XF86KbdBrightnessUp"];
    media-static = ["XF86AudioMedia"];
    mic-mute-static = ["XF86AudioMicMute"];
    next-static = ["XF86AudioNext" "<Ctrl>XF86AudioNext"];
    pause-static = ["XF86AudioPause"];
    play-static = ["XF86AudioPlay" "<Ctrl>XF86AudioPlay"];
    playback-forward-static = ["XF86AudioForward"];
    playback-random-static = ["XF86AudioRandomPlay"];
    playback-repeat-static = ["XF86AudioRepeat"];
    playback-rewind-static = ["XF86AudioRewind"];
    power-static = ["XF86PowerOff"];
    previous-static = ["XF86AudioPrev" "<Ctrl>XF86AudioPrev"];
    rfkill-bluetooth-static = ["XF86Bluetooth"];
    rfkill-static = ["XF86WLAN" "XF86UWB" "XF86RFKill"];
    rotate-video-lock-static = ["<Super>o" "XF86RotationLockToggle"];
    screen-brightness-cycle-static = ["XF86MonBrightnessCycle"];
    screen-brightness-down-static = ["XF86MonBrightnessDown"];
    screen-brightness-up-static = ["XF86MonBrightnessUp"];
    screensaver-static = ["XF86ScreenSaver"];
    search-static = ["XF86Search"];
    stop-static = ["XF86AudioStop"];
    suspend-static = ["XF86Sleep"];
    touchpad-off-static = ["XF86TouchpadOff"];
    touchpad-on-static = ["XF86TouchpadOn"];
    touchpad-toggle-static = ["XF86TouchpadToggle" "<Ctrl><Super>XF86TouchpadToggle"];
    volume-down-precise-static = ["<Shift>XF86AudioLowerVolume" "<Ctrl><Shift>XF86AudioLowerVolume"];
    volume-down-quiet-static = ["<Alt>XF86AudioLowerVolume" "<Alt><Ctrl>XF86AudioLowerVolume"];
    volume-down-static = ["XF86AudioLowerVolume" "<Ctrl>XF86AudioLowerVolume"];
    volume-mute-quiet-static = ["<Alt>XF86AudioMute"];
    volume-mute-static = ["XF86AudioMute"];
    volume-up-precise-static = ["<Shift>XF86AudioRaiseVolume" "<Ctrl><Shift>XF86AudioRaiseVolume"];
    volume-up-quiet-static = ["<Alt>XF86AudioRaiseVolume" "<Alt><Ctrl>XF86AudioRaiseVolume"];
    volume-up-static = ["XF86AudioRaiseVolume" "<Ctrl>XF86AudioRaiseVolume"];
    www-static = ["XF86WWW"];
  };

  cfg = config.dconf.gsd;

  boundKeys =
    map ({binding, ...}: binding)
    (attrValues cfg.plugins.media-keys.customBindings);

  changedStaticKeys =
    # static keys used in custom bindings
    optionals cfg.plugins.media-keys.overrideStatic
    # only keep changed keys
    (filter
      (binding:
        getAttr binding.name staticKeys != binding.value)
      (attrsToList
        # empty mappings should be [ "" ]
        (mapAttrs
          (name: value:
            if length value != 0
            then value
            else [""])
          # only keep keys not bound otherwise
          (mapAttrs
            (name: value: filter (key: !elem key boundKeys) value)
            staticKeys))));

  customBindingModule = types.submodule {
    options = {
      binding = mkOption {
        type = types.str;
        example = "XF86Calculator";
        description = "XKB key name";
      };

      command = mkOption {
        type = types.str;
        description = "sh command to execute";
      };

      name = mkOption {
        type = types.str;
        description = "display name for the binding";
      };
    };
  };
in {
  options.dconf.gsd.plugins = {
    media-keys = {
      overrideStatic = mkOption {
        type = types.bool;
        default = false;
        description = "override static bindings";
      };

      customBindings = mkOption {
        type = types.attrsOf customBindingModule;
        default = [];
        example = {
          terminal = {
            binding = "XF86Calculator";
            command = "''${pkgs.blackbox-terminal}/bin/blackbox";
            name = "Open Terminal";
          };
        };
      };
    };
  };

  config = {
    dconf.settings =
      {
        "org/gnome/settings-daemon/plugins/media-keys" =
          {
            # remove the static binding preventing users from remapping the calculator key
            custom-keybindings =
              map
              (name: "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/${name}/")
              (attrNames cfg.plugins.media-keys.customBindings);
          }
          // listToAttrs changedStaticKeys;
      }
      // listToAttrs
      (map
        ({
          name,
          value,
        }:
          nameValuePair
          "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/${name}"
          value)
        (attrsToList cfg.plugins.media-keys.customBindings));
  };
}
