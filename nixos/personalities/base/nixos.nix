{ pkgs, ... }: {
    nix = {
        settings = {
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