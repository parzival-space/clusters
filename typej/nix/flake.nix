{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, colmena, sops-nix, nixos-hardware, ... }:
  {
    colmenaHive = colmena.lib.makeHive {
      meta = {
        nixpkgs = import nixpkgs {
          system = "x86_64-linux";
        };
        specialArgs = { inherit sops-nix nixos-hardware; };
      };

      pi4-agent1 = {
        nixpkgs.system = "aarch64-linux";

        deployment = {
          targetHost = "pi4-agent1.typej";
          targetPort = 22;
          targetUser = "nixos";
          tags = [ "typej" ];
        };

        imports = [
          ./nodes/pi4-agent1/configuration.nix
        ];
      };

      pi4-agent2 = {
        nixpkgs.system = "aarch64-linux";

        deployment = {
          targetHost = "10.0.0.96"; # pi4-agent2.typej
          targetPort = 22;
          targetUser = "parzival";
          tags = [ "typej" ];
        };

        imports = [
          ./nodes/pi4-agent2/configuration.nix
        ];
      };
    };
  };
}
