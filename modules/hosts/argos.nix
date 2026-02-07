{
  __findFile,
  ...
}:
{
  den.hosts.x86_64-linux.argos.users.talarys = { };

  den.aspects.argos = {
    nixos =
      { lib, ... }:
      {
        imports = [ ];

        boot.initrd.availableKernelModules = [
          "sd_mod"
          "sr_mod"
        ];

        disko.devices.disk.nvme.device = lib.mkForce "/dev/nvme1n1";
      };

    includes = [
      <disko/btrfs>
      <overlays>

      <system/systemd-boot>
      <system/locale>
      <system/ssh>
      <system/audio>
      <system/fonts>
      <system/networking>
      <system/nvidia>
      <system/gaming>
      <system/xdg>

      <desktop/sddm>
      <desktop/kde>

      <apps/apps>
      <apps/ghostty>
      <apps/kitty>
      <apps/mpv>
      <apps/vicinae>
      <apps/zen>
    ];
  };
}
