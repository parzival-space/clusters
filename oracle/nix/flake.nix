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

        a1flex-server1 = {
          nixpkgs.system = "aarch64-linux";
          deployment = {
            targetHost = "a1flex-server1.oracle.cluster.parzival.space";
            targetPort = 22;
            targetUser = "parzival";
            buildOnTarget = true;
            tags = [ "oracle" ];
          };
          imports = [
            ./nodes/a1flex-server1/configuration.nix
          ];
        };
      };
    };
}
