{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, colmena, sops-nix, ... }:
  {
    colmenaHive = colmena.lib.makeHive {
      meta = {
        nixpkgs = import nixpkgs {
          system = "x86_64-linux";
        };
        specialArgs = { inherit sops-nix; };
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
    };
  };
}
