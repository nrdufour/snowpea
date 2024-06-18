{ 
  ## Nothing for now as the core module from nixos-rk3588 is taking care of it

  # The orange pis use an SSD
  services.fstrim.enable = true;
}