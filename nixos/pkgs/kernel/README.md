# Linux Kernel

The armbian's developers have done a lot of work to make the kernel work on RK3588/RK3588S based boards, and This Flake is based on their work.

## Armbian Kernel

Kernel and the build system:

- <https://github.com/armbian/build>
- <https://github.com/armbian/linux-rockchip>

Other informations:

- the SBC specific build configuration:
  - <https://github.com/armbian/build/blob/main/config/boards/orangepi5.conf>
  - <https://github.com/armbian/build/blob/main/config/boards/orangepi5-plus.conf>
  - <https://github.com/armbian/build/blob/main/config/boards/rock-5a.wip>
  - useful options defined in the above files:
    - BOARDFAMILY: choose the right board family, which will be used below.
    - BOOT_FDT_FILE: the dtb file name.
    - for some boards, the `BOOTSOURCE` is overridden to a different repo.
      - e.g. orangepi5/orangepi5plus: the `BOOTSOURCE` is overridden to https://github.com/orangepi-xunlong/u-boot-orangepi.git
- Board Families
  - `BOARDFAMILY="rockchip-rk3588"`:
    - source: https://github.com/armbian/build/blob/main/config/sources/families/rockchip-rk3588.conf
    - uboot: `BOOTSOURCE='https://github.com/radxa/u-boot.git'`
    - BRANCH:
      - legacy: the legacy 5.10, just ignore it.
      - vendor: kernel 6.1, maintained by armbian/rockchip.
        - `LINUXFAMILY=rk35xx`
        - `KERNELPATCHDIR='rk35xx-vendor-6.1'`
- the kernel config:
  - default to `LINUXCONFIG="linux-${LINUXFAMILY}-${BRANCH}"` + `.config`
    - defined at:
      - https://github.com/armbian/build/blob/main/lib/functions/configuration/main-config.sh#L291
      - https://github.com/armbian/build/blob/main/lib/functions/compilation/kernel-config.sh#L14-L22
  - so the default kernel config(defconfig) for orangepi5 / orangepi5plus / rock-5a is:
    - BRANCH=vendor: <https://github.com/armbian/build/blob/main/config/kernel/linux-rk35xx-vendor.config>
    - defconfig is generated by vendor or armbian, they disabled some unsupported features & drivers to
      make the kernel work on the board, and enabled rk3588 specific features & drivers(such as rknpu).
- the initial commit for orangepi5 in armbian/build:
  - <https://github.com/armbian/build/commit/18198b1d7d72cbef44228e7cb44a078cb8e03f27#diff-999cd9038268b0c128f7342a957b87fa0b4b12536e4cd2abd54c9a17180188e1>

The SBC's kernel config in this directory is based on the armbian's kernel config listed above.

## Orange Pi's Kernel

Kernel and the build system, it's very similar to armbian's:

- <https://github.com/armbian/build/>
- <https://github.com/orangepi-xunlong/linux-orangepi>

Orange Pi 5/4+'s kernel 6.1 support:

- Kernel: <https://github.com/orangepi-xunlong/linux-orangepi/tree/orange-pi-6.1-rk35xx>
- Build System: <https://github.com/orangepi-xunlong/orangepi-build/commit/55155f1d73cca3cf6bf42a03d7d16df2b14e8014>
  - the defconfig: <https://github.com/orangepi-xunlong/orangepi-build/blob/next/external/config/kernel/linux-rockchip-rk3588-current.config>


## References

- [RK3588 Mainline Kernel support - Rockchip RK3588 upstream enablement efforts](https://gitlab.collabora.com/hardware-enablement/rockchip-3588/notes-for-rockchip-3588/-/blob/main/mainline-status.md)