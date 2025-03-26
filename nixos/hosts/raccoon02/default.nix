{ pkgs, ... }: {

  networking.hostName = "raccoon02";

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

    # "/var/lib/rancher" =
    #   {
    #     device = "/dev/disk/by-id/usb-Samsung_Flash_Drive_FIT_0310522060008959-0:0";
    #     fsType = "ext4";
    #   };
  };
  
}
