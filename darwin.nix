{
  self,
  nix-darwin,
  mac-app-util,
  home-manager,
  nix-homebrew,
  ...
}:
let
  user = {
    name = "troy";
    home = "/Users/troy";
  };

  modules = [
    {
      nix = {
        settings = {
          experimental-features = "nix-command flakes";
        };
      };

      nixpkgs = {
        hostPlatform = "aarch64-darwin";
        config = {
          allowUnfree = true;
        };
      };

      system = {
        primaryUser = user.name;
        configurationRevision = self.rev or self.dirtyRev or null;
        stateVersion = 5;
      };

      users.users.${user.name} = user;
    }

    mac-app-util.darwinModules.default

    home-manager.darwinModules.home-manager
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        sharedModules = [ mac-app-util.homeManagerModules.default ];
        users.${user.name} = import ./home.nix;
      };
    }

    nix-homebrew.darwinModules.nix-homebrew
    {
      nix-homebrew = {
        enable = true;
        user = user.name;
      };
    }

    (import ./darwin/brew.nix)
    (import ./darwin/ssh.nix)
    (import ./darwin/machine.common.nix)
  ];
in
{
  # iMac
  "C02YT06DJV3Y" = nix-darwin.lib.darwinSystem {
    modules = modules ++ [
      (import ./darwin/machine.desktop.nix)
      { networking.hostName = "play-imac"; }
    ];
  };

  # 2025 MacBook Pro
  "H6J7XDDGHD" = nix-darwin.lib.darwinSystem {
    modules = modules ++ [
      (import ./darwin/machine.laptop.nix)
      { networking.hostName = "troy-mpb"; }
    ];
  };
}
