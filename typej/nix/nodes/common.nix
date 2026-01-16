{ pkgs, ... }:
{
  imports = [
    ./users.nix
  ];

  # Configure Nix
  nix = {
    settings = {
      auto-optimise-store = true;
      trusted-users = [
        "root"
        "@wheel"
      ];
    };

    # Enable periodic garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };
  nixpkgs.config.allowUnfree = true;

  # Security
  security.sudo.wheelNeedsPassword = false;

  # Firewall
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];

  # Enable SSH
  services.openssh = {
    enable = true;
    permitRootLogin = "no";
    settings = {
      PasswordAuthentication = false;
      PubkeyAuthentication = true;
    };
  };

  # Common packages
  environment.systemPackages = with pkgs; [
    nano
    git
    curl
  ];

  # Localization
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Keymaps
  console.keyMap = "us-acentos";
  services.xserver.xkb = {
    layout = "us";
    variant = "intl";
  };
}
