{ config, lib, pkgs, imports, boot, self, ... }:
# Role for headless servers
# covers raspi's, sbc, NUC etc, anything
# that is headless and minimal for running services

with lib;
{

  config = {

    # Enable monitoring for remote scraiping
    mySystem.services.monitoring.enable = true;
    # Check if a reboot is necessary
    mySystem.services.rebootRequiredCheck.enable = true;
  };

}