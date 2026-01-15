{
  den.aspects.system._.no-boot = {
    description = "Disables booting for testing";
    nixos = {
      boot.loader.grub.enable = false;
      fileSystems."/".device = "/dev/null";
    };
  };
}
