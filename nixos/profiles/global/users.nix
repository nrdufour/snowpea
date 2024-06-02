{ pkgs, config, ... }:
let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  users.users.ndufour = {
    isNormalUser = true;
    home = "/home/ndufour";
    shell = pkgs.fish;
    description = "Nicolas Dufour";
    extraGroups = 
      [
        "wheel"
        "networkmanager"
      ]
      ++ ifTheyExist [
        "network"
        "docker"
        "podman"
        "audio" # pulseaudio
        "libvirtd"
      ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAAjRgUY8iJkzNdbWvMv65NZmcWx3DSUCnv/FMw63nxl nrdufour@gmail.com"
    ];
  };

  # Direct dependency from the user
  programs.fish.enable = true;
}