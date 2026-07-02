{
  description = "My system configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    sops_secrets = {
      url = "git+ssh://git@github.com/green-lad/sops_secrets?shallow=1";
      flake = false;
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-your-shell = {
      url = "github:MercuryTechnologies/nix-your-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helix = {
      url = "github:helix-editor/helix/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri-flake = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    uwu-colors = {
      url = "github:q60/uwu_colors";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    additional-fonts = {
      url = "github:green-lad/fonts";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wrapper-manager = {
      url = "github:viperML/wrapper-manager";
      # warning for the following uncommented: "warning: input 'wrapper-manager' has an override for a non-existent input 'nixpkgs'"
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence = {
      url = "github:nix-community/impermanence";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      disko,
      sops-nix,
      stylix,
      impermanence,
      additional-fonts,
      ...
    }@inputs:
    let
      overlays = [
        inputs.nix-your-shell.overlays.default
        (import ./pkgs)
      ];
      hosts = {
        nuc = {
          hostname = "nuc";
          hostPlatform_system = "x86_64-linux";
          users = [ "markus" ];
          unfreePackages = [
            "android-studio"
            "lightburn"
            "rustdesk"
            "steam"
            "tk-safe"
          ];
          domain = "greenlad.net";
        };
        rad = {
          hostname = "rad";
          hostPlatform_system = "x86_64-linux";
          users = [ "markus" ];
          unfreePackages = [
            "lightburn"
            "steam"
            "tk-safe"
          ];
          domain = "greenlad.net";
        };
        x13 = {
          hostname = "x13";
          hostPlatform_system = "x86_64-linux";
          users = [ "markus" ];
          unfreePackages = [
            "lightburn"
            "steam"
            "tk-safe"
          ];
          domain = "greenlad.net";
        };
        x230 = {
          hostname = "x230";
          hostPlatform_system = "x86_64-linux";
          users = [ "markus" ];
          unfreePackages = [ "lightburn" ];
          domain = "greenlad.net";
        };
      };
    in
    {
      nixosConfigurations = builtins.mapAttrs (
        n: v:
        nixpkgs.lib.nixosSystem {
          system = v.hostPlatform_system;
          specialArgs = {
            inherit inputs;
            user = builtins.head v.users;
            hostname = v.hostname;
            domain = v.domain;
            hosts = hosts;
          };
          modules = [
            {
              nixpkgs.overlays = overlays;
              nixpkgs.config.allowUnfree = true;
              nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) v.unfreePackages;
            }
            impermanence.nixosModules.impermanence
            stylix.nixosModules.stylix
            disko.nixosModules.disko
            sops-nix.nixosModules.sops
            ./nixos/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users = {
                "${builtins.head v.users}" = import ./home-manager/home.nix;
              };
              home-manager.extraSpecialArgs = {
                inherit inputs;
                user = builtins.head v.users;
                hostname = v.hostname;
                system = v.hostPlatform_system;
                hosts = hosts;
              };
            }
          ];
        }
      ) hosts;

      homeConfigurations = builtins.mapAttrs (
        n: v:
        home-manager.lib.homeManagerConfiguration {
          pkgs = (
            import nixpkgs {
              inherit overlays;
              system = v.hostPlatform_system;
              config = {
                allowUnfree = true;
                allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) v.unfreePackages;
              };
            }
          );
          modules = [
            stylix.homeModules.stylix
            ./home-manager/home.nix
          ];
          extraSpecialArgs = {
            inherit inputs;
            user = builtins.head v.users;
            hostname = v.hostname;
            system = v.hostPlatform_system;
            hosts = hosts;
          };
        }
      ) hosts;
    };
}
