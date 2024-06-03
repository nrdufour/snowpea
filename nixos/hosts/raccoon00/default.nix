{ pkgs, ... }: {

  networking.hostName = "raccoon00";

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
        device = "/dev/disk/by-id/usb-Samsung_Flash_Drive_FIT_0362022060009147-0:0";
        fsType = "ext4";
      };
  };
  
}
