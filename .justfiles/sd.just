# SD card image management commands

# Build the SD card image for a host
sd-build host:
    nix build -L .#nixosConfigurations.{{host}}.config.system.build.sdImage

# Flash the SD card image (with rpi-imager)
sd-flash host:
    just sd-build {{host}}
    nix-shell -p rpi-imager --run "QT_QPA_PLATFORM=wayland rpi-imager ./result/sd-image/{{host}}.img.zst"
