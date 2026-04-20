{
  inputs,
  __findFile,
  ...
}:
{
  den.hosts.x86_64-linux.argos.users.talarys = { };

  den.aspects.argos = {
    nixos =
      { lib, pkgs, ... }:
      {
        imports = [ ];

        nixpkgs.overlays = [
          inputs.nix-cachyos-kernel.overlays.default
        ];

        boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-zen4;

        boot.initrd.availableKernelModules = [
          "sd_mod"
          "sr_mod"
        ];

        disko.devices.disk.nvme.device = lib.mkForce "/dev/nvme1n1";

        fileSystems."/mnt/NVME S" = {
          device = "/dev/disk/by-uuid/44A8CCACA8CC9E34";
          fsType = "ntfs";
        };

        fileSystems."/mnt/NVME K" = {
          device = "/dev/disk/by-uuid/54EE2B1DEE2AF6C0";
          fsType = "ntfs";
        };
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
