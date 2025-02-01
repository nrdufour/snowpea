{ pkgs, ... }: {

  networking.hostName = "raccoon03";

  fileSystems = {
    "/" =
      {
        device = "/dev/disk/by-label/NIXOS_SD";
        fsType = "ext4";
      };

    "/boot/firmware" =
      {
        device = "/dev/disk/by-label/FIRMWARE";
        fsType = "vfat";
      };

    "/var/lib/rancher" =
      {
        device = "/dev/disk/by-label/STORAGE";
        fsType = "ext4";
      };
  };

  mySystem.services.k3s.additionalFlags = toString [
    "--node-label svccontroller.k3s.cattle.io/enablelb=true"
    "--node-label svccontroller.k3s.cattle.io/lbpool=internal"
  ];

}
