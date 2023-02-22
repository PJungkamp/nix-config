{...}:
# Enable sound with pipewire.
{
  config = {
    sound.enable = true;
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    environment.etc."wireplumber/main.lua.d/89-disable-libcamera-monitor.lua" = {
      text = ''
        -- the libcamera module does not close the device on node suspend
        libcamera_monitor.enabled = false
      '';
    };
  };
}
