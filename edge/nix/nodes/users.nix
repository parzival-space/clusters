{ pkgs, ... }:
{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.parzival = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIXyF0hBecCSv1a3iVTf2RF8PldSQTRtJ5qBy0okoslP parzival@battlestation"
    ];
  };
}
