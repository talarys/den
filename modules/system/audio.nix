{
  system,
  ...
}:
{
  system.audio.nixos =
    { pkgs, ... }:
    {
      security.rtkit.enable = true;

      services.pipewire = {
        enable = true;
        audio.enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        # `jack.enable` is deprecated (global LD_LIBRARY_PATH impurity); use the
        # `pw-jack` wrapper from `pkgs.pipewire.jack` when a JACK client needs it.
      };

      environment.systemPackages = with pkgs; [
        pavucontrol # PulseAudio volume control
        playerctl # Media player control
        easyeffects # PipeWire effects
      ];
    };
}
