{ pkgs, ... }: {

  networking.hostName = "raccoon05";

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

}
