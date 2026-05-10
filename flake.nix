{
  description = "NixOS desktop — Hyprland, dev + gaming";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    claude-code.url = "github:sadjow/claude-code-nix";
    claude-desktop-flake.url = "github:k3d3/claude-desktop-linux-flake";

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    savepoint.url = "github:NamtaoProductions/savepoint";

    zen-browser.url = "github:0xc000022070/zen-browser-flake";
  };

  outputs = { self, nixpkgs, home-manager, claude-code, claude-desktop-flake, firefox-addons, savepoint, zen-browser, ... }: {
    nixosConfigurations.april = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        home-manager.nixosModules.home-manager
        ./hosts/april
        { nixpkgs.overlays = [ claude-code.overlays.default ]; }
        {
          environment.systemPackages = [
            claude-desktop-flake.packages.x86_64-linux.claude-desktop
          ];
        }

        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = { inherit firefox-addons savepoint zen-browser; };
            backupFileExtension = "hm-backup";
            users.polls = import ./home;
          };
        }
      ];
    };
  };
}
