{
  __findFile,
  inputs,
  ...
}:
{
  den.hosts.x86_64-linux.vm.users.talarys = { };

  den.aspects.vm = {
    nixos = {
      imports = [ ];

      virtualisation.hypervGuest.enable = true;

      boot.initrd.availableKernelModules = [
        "sd_mod"
        "sr_mod"
      ];
    };

    includes = [
      <disko/simple>
      <overlays>
      <system/systemd-boot>
      <system/locale>
      <system/ssh/client>
      <system/ssh/server>
    ];
  };
}
