{
  lib,
  config,
  nixpkgs,
  pkgs,
  ...
}:
let
  rootPartitionUUID = "14e19a7b-0ae0-484d-9d54-43bd6fdc20c7";
in
{
  imports = [
    "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
  ];

  boot = {
    loader = {
      grub.enable = lib.mkForce false;
      generic-extlinux-compatible.enable = lib.mkForce true;
    };

    supportedFilesystems = lib.mkForce [
      "vfat"
      "fat32"
      "exfat"
      "ext4"
      "btrfs"
    ];

    kernelPackages = pkgs.linuxPackagesFor (pkgs.callPackage ../pkgs/kernel/vendor.nix {});

    # kernelParams copy from Armbian's /boot/armbianEnv.txt & /boot/boot.cmd
    kernelParams = [
      "root=UUID=${rootPartitionUUID}"
      "rootfstype=ext4"

      "rootwait"

      "earlycon" # enable early console, so we can see the boot messages via serial port / HDMI
      "consoleblank=0" # disable console blanking(screen saver)
      "console=ttyS2,1500000" # serial port
      "console=tty1" # HDMI

      # docker optimizations
      "cgroup_enable=cpuset"
      "cgroup_memory=1"
      "cgroup_enable=memory"
      "swapaccount=1"
    ];

    # Some default kernel modules are not available in our kernel,
    # so we have not to include them in the initrd.
    # All the default modules are listed here:
    #   https://github.com/NixOS/nixpkgs/blob/nixos-23.11/nixos/modules/system/boot/kernel.nix#L257
    #
    # How I found this out:
    #   ```
    #   $ grep -r 'includeDefaultModules' ./nixpkgs/
    #   /etc/nix/inputs/nixpkgs/nixos/modules/system/boot/kernel.nix:    boot.initrd.includeDefaultModules = mkOption {
    #   /etc/nix/inputs/nixpkgs/nixos/modules/system/boot/kernel.nix:          optionals config.boot.initrd.includeDefaultModules ([
    #   /etc/nix/inputs/nixpkgs/nixos/modules/system/boot/kernel.nix:          optionals config.boot.initrd.includeDefaultModules [
    #   ```
    initrd.includeDefaultModules = lib.mkForce false;
    # Instead, we include only the modules we need for booting.
    # NOTE: this is just the modules for booting, not the modules for the system!
    # So you don't need to worry about missing modules for your hardware.
    #
    # To find out which modules you may need:
    #   ```
    #    $ grep -r 'availableKernelModules' ./nixpkgs/
    #   ```
    initrd.availableKernelModules = lib.mkForce [
      # NVMe
      "nvme"

      # SD cards and internal eMMC drives.
      "mmc_block"

      # Support USB keyboards, in case the boot fails and we only have
      # a USB keyboard, or for LUKS passphrase prompt.
      "hid"

      # For LUKS encrypted root partition.
      # https://github.com/NixOS/nixpkgs/blob/nixos-23.11/nixos/modules/system/boot/luksroot.nix#L985
      "dm_mod" # for LVM & LUKS
      "dm_crypt" # for LUKS
      "input_leds"
    ];
  };

  sdImage = {
    inherit rootPartitionUUID;
    compressImage = true;

    # install firmware into a separate partition: /boot/firmware
    populateFirmwareCommands = ''
      ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./firmware
    '';
    # Gap in front of the /boot/firmware partition, in mebibytes (1024×1024 bytes).
    # Can be increased to make more space for boards requiring to dd u-boot SPL before actual partitions.
    firmwarePartitionOffset = 32;
    firmwarePartitionName = "BOOT";
    firmwareSize = 200; # MiB

    populateRootCommands = ''
      mkdir -p ./files/boot
    '';
  };

  # add some missing deviceTree in armbian/linux-rockchip:
  # orange pi 5 plus's deviceTree in armbian/linux-rockchip:
  #    https://github.com/armbian/linux-rockchip/blob/rk-5.10-rkr4/arch/arm64/boot/dts/rockchip/rk3588-orangepi-5-plus.dts
  hardware = {
    deviceTree = {
      # https://github.com/armbian/build/blob/f9d7117/config/boards/orangepi5-plus.wip#L10C51-L10C51
      name = "rockchip/rk3588-orangepi-5-plus.dtb";
      overlays = [
      ];
    };

    firmware = [
      (pkgs.callPackage ../pkgs/orangepi-firmware {})
    ];

    graphics.enable = true;
    # graphics.package =
    #   (pkgs.mesa.override {
    #     galliumDrivers = ["panfrost"];
    #     vulkanDrivers = ["swrast"];
    #   }).drivers;

    enableRedistributableFirmware = lib.mkForce true;
  };

  # The orange pis use an SSD
  services.fstrim.enable = true;
}