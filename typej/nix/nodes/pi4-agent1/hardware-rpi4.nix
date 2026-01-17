{ config, lib, pkgs, nixos-hardware, ... }:
{
  imports = [ nixos-hardware.nixosModules.raspberry-pi-4 ];

  hardware = {
    raspberry-pi."4".apply-overlays-dtmerge.enable = true;
    deviceTree = {
      enable = true;
      filter = "*rpi-4-*.dtb";
    };
  };
  console.enable = false;
}
