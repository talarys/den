{
  __findFile,
  inputs,
  ...
}:
{
  den.hosts.x86_64-linux.vm.users.talarys = { };

  den.aspects.vm = {
    nixos = {
      imports = [ ../../disko/simple.nix ];

      virtualisation.hypervGuest.enable = true;

      boot.initrd.availableKernelModules = [
        "sd_mod"
        "sr_mod"
      ];
    };

    includes = [
      <system/systemd-boot>
      <system/locale>
      <system/ssh>
      <system/audio>
      <system/fonts>
      <system/networking>
      # <system/xdg>

      <desktop/sddm>
      <desktop/kde>
      <desktop/niri>
      <desktop/plymouth>
      # <desktop/catppuccin>

      <apps/apps>
      <apps/ghostty>
      <apps/kitty>
      <apps/mpv>
      <apps/vicinae>
      <apps/zen>
    ];
  };
}
