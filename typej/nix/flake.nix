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

    # nixinate as alternative to colmena, might be phased out later
    nixinate.url = "github:matthewcroughan/nixinate";
    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-hardware, nixos-raspberrypi, sops-nix, colmena, nixinate }@inputs: {

    colmenaHive = inputs.colmena.lib.makeHive ({
      meta = {
        nixpkgs = import inputs.nixpkgs { system = "x86_64-linux"; };
        nodeNixpkgs = builtins.mapAttrs (name: value: value.pkgs) self.nixosConfigurations;
        nodeSpecialArgs = builtins.mapAttrs (name: value: value._module.specialArgs) self.nixosConfigurations;
      };
    } // builtins.mapAttrs (name: value: {
      nixpkgs.system = value.pkgs.stdenv.hostPlatform.system;
      imports = value._module.args.modules;
    }) self.nixosConfigurations);

    apps = nixinate.nixinate.x86_64-linux self;

    nixosConfigurations = {
      pi5-master1 = inputs.nixos-raspberrypi.lib.nixosSystem {
        specialArgs = inputs;
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
          (import ./nodes/pi5-master1/configuration.nix)
          {
            _module.args.nixinate = {
              host = "pi5-master1.typej";
              sshUser = "parzival";
            };
          }
        ];
      };


      neo50q-agent1 = nixpkgs.lib.nixosSystem {
        specialArgs = inputs;
        modules = [
          (import ./nodes/neo50q-agent1/configuration.nix)
          {
            _module.args.nixinate = {
              host = "neo50q-agent1.typej";
              sshUser = "parzival";
            };
          }
        ];
      };

      pi4-agent1 = nixpkgs.lib.nixosSystem {
        specialArgs = inputs;
        modules = [
          (import ./nodes/pi4-agent1/configuration.nix)
          {
            _module.args.nixinate = {
              host = "pi4-agent1.typej";
              sshUser = "parzival";
            };
          }
        ];
      };

      pi4-agent2 = nixpkgs.lib.nixosSystem {
        specialArgs = inputs;
        modules = [
          (import ./nodes/pi4-agent2/configuration.nix)
          {
            _module.args.nixinate = {
              host = "pi4-agent2.typej";
              sshUser = "parzival";
            };
          }
        ];
      };

      pi4-agent3 = nixpkgs.lib.nixosSystem {
        specialArgs = inputs;
        modules = [
          (import ./nodes/pi4-agent3/configuration.nix)
          {
            _module.args.nixinate = {
              host = "pi4-agent3.typej";
              sshUser = "parzival";
            };
          }
        ];
      };

      pi4-agent4 = nixpkgs.lib.nixosSystem {
        specialArgs = inputs;
        modules = [
          (import ./nodes/pi4-agent4/configuration.nix)
          {
            _module.args.nixinate = {
              host = "pi4-agent4.typej";
              sshUser = "parzival";
            };
          }
        ];
      };
    };
  };
}
