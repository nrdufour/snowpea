{ pkgs, ... }: {
    nix = {
        settings = {
            trusted-substituters = [
              "https://nix-community.cachix.org"
              "https://numtide.cachix.org"
              "https://nrdufour.cachix.org"
            ];

            trusted-public-keys = [
              "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
              "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
              "nrdufour.cachix.org-1:nwmZmZ3b4h4cEJtIRib7trk8SVB49trCnlxVSNz0YQs="
            ];

            # Fallback quickly if substituters are not available.
            connect-timeout = 5;

            experimental-features = [ "nix-command" "flakes" ];
        };
        gc = {
            automatic = true;
            dates = "weekly";
            # Delete older generations too
            options = "--delete-older-than 2d";
        };
    };

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;
}
