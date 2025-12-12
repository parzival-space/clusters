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

        g11-server1 = {
          deployment = {
            targetHost = "g11-server1.edge.cluster.parzival.space";
            targetPort = 22;
            targetUser = "parzival";
            tags = [ "edge" ];
          };
          imports = [
            ./nodes/g11-server1/configuration.nix
          ];
        };
      };
    };
}
