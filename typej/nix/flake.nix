{
  description = "NixOS configurations for the TypeJ mini-rack cluster";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/main";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-hardware, nixos-raspberrypi, sops-nix, colmena }@inputs: {

    colmena = {
      meta = {
        nixpkgs = import inputs.nixpkgs { system = "x86_64-linux"; };
        nodeNixpkgs = builtins.mapAttrs (name: value: value.pkgs) self.nixosConfigurations;
        nodeSpecialArgs = builtins.mapAttrs (name: value: value._module.specialArgs) self.nixosConfigurations;
      };
    } // builtins.mapAttrs (name: value: { imports = value._module.args.modules; }) self.nixosConfigurations;
    colmenaHive = inputs.colmena.lib.makeHive self.colmena;

    nixosConfigurations = {
      pi5-master1 = inputs.nixos-raspberrypi.lib.nixosSystem {
        specialArgs = inputs;
        extraModules = [ inputs.colmena.nixosModules.deploymentOptions ];
        modules = [
          {
            # Hardware specific configuration
            imports = with nixos-raspberrypi.nixosModules; [
              raspberry-pi-5.base
              raspberry-pi-5.page-size-16k
              raspberry-pi-5.display-vc4
              raspberry-pi-5.bluetooth
            ];
          }

          ../nix/nodes/pi5-master1/configuration.nix
        ];
      };

      neo50q-agent1 = nixpkgs.lib.nixosSystem {
        specialArgs = inputs;
        modules = [
          ./nodes/neo50q-agent1/configuration.nix ];
      };

      pi4-agent1 = nixpkgs.lib.nixosSystem {
        specialArgs = inputs;
        modules = [ ./nodes/pi4-agent1/configuration.nix ];
      };

      pi4-agent2 = nixpkgs.lib.nixosSystem {
        specialArgs = inputs;
        modules = [ ./nodes/pi4-agent2/configuration.nix ];
      };

      pi4-agent3 = nixpkgs.lib.nixosSystem {
        specialArgs = inputs;
        modules = [ ./nodes/pi4-agent3/configuration.nix ];
      };

      pi4-agent4 = nixpkgs.lib.nixosSystem {
        specialArgs = inputs;
        modules = [ ./nodes/pi4-agent4/configuration.nix ];
      };
    };
  };
}
