{ pkgs, ... }: {

  services.gitea = {
    enable = true;
    appName = "My awesome Gitea server"; # Give the site a name
  };

  environment.systemPackages = with pkgs; [
    gitea
  ];
}