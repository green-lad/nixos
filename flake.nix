{
  description = "My system configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # linuxcnc-nix = {
    #   url = "github:mattywillo/linuxcnc-nix";
    # };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops_secrets = {
      url = "git+ssh://git@github.com/green-lad/sops_secrets?shallow=1";
      flake = false;
    };

    nix-your-shell = {
      url = "github:MercuryTechnologies/nix-your-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helix.url = "github:helix-editor/helix/master";
    # wezterm.url = "github:wez/wezterm?dir=nix";
    # niri.url = "github:yalter/niri";

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri-flake.url = "github:sodiboo/niri-flake";

    uwu-colors.url = "github:q60/uwu_colors";

    additional-fonts = {
      url = "github:green-lad/fonts";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nsticky.url = "github:lonerOrz/nsticky";

    wrapper-manager.url = "github:viperML/wrapper-manager";
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      disko,
      sops-nix,
      stylix,
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
          };
          modules = [
            {
              nixpkgs.overlays = overlays;
              nixpkgs.config.allowUnfree = true;
              nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) v.unfreePackages;
            }
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
          };
        }
      ) hosts;
    };
}
