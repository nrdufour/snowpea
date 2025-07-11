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

  # Avoid using UAS driver for this usb device, as it's not stable with the raspberry pi 4
  # See https://www.reddit.com/r/NixOS/comments/okpz7w/rpi4_nixos_quirks_for_ssd_with_usb3_uasp_problem/
  # and https://forums.raspberrypi.com/viewtopic.php?f=28&t=245931&sid=d8df335a2e30668e9852048027efba3b
  # and https://linux-sunxi.org/USB/UAS
  boot.kernelParams = [
    "usb-storage.quirks=174c:2362:u"
    "usbcore.quirks=174c:2362:u"
  ];

  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
    dates = "03:00";
    flake = "git+https://forge.internal/nemo/snowpea.git";
  };

}
