{
  users.users.ndufour = {
    isNormalUser = true;
    home = "/home/ndufour";
    description = "Nicolas Dufour";
    extraGroups = [ "wheel" "networkmanager" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAAjRgUY8iJkzNdbWvMv65NZmcWx3DSUCnv/FMw63nxl nrdufour@gmail.com"
    ];
  };
}
