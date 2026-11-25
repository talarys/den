{
  system,
  ...
}:
{
  system.virt = {
    nixos =
      { pkgs, ... }:
      {
        boot.kernelModules = [ "kvm-amd" ];

        environment.systemPackages = with pkgs; [
          qemu_kvm
          quickemu
          quickgui
          virt-manager
          virt-viewer
          spice
          spice-gtk
          spice-protocol
          win-virtio
          win-spice
        ];

        virtualisation = {
          libvirtd = {
            enable = true;
            qemu = {
              package = pkgs.qemu_kvm;
              swtpm.enable = true;
              ovmf.enable = true;
              ovmf.packages = [ pkgs.OVMFFull.fd ];
            };
          };
          spiceUSBRedirection.enable = true;
        };
        services.spice-vdagentd.enable = true;
      };

    # Group membership is a per-user property: the `user` class routes to
    # `users.users.<name>` for every user the host owns.
    provides.to-users.user.extraGroups = [
      "libvirtd"
      "kvm"
    ];
  };
}
