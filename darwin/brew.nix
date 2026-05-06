{ config, pkgs, ... }:
let
  # mas must run inside the user's launchd session to reach the App Store daemon.
  # nix-darwin's homebrew activation runs as root, so masApps fails regardless of
  # HOME. Use launchctl asuser + sudo -u to run mas in the correct session instead.
  masApps = {
    "magnet" = 441258766;
    "xcode" = 497799835;
  };
in
{
  homebrew = {
    enable = true;

    onActivation.cleanup = "zap";
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;

    taps = [
      "hashicorp/tap"
      "jmalloc/grit"
      "kcl-lang/tap"
    ];

    brews = [
      "adr-tools" # No Nix package. TODO: Try "adrs" Nix package.
      "clang-format" # For formatting .proto files in Visual Studio Code
      "hashicorp/tap/tfstacks" # No Nix package.
      "jmalloc/grit/grit" # No Nix package.
      "kcl-lang/tap/kcl-lsp" # No Nix package.
      "mise" # Nix package is much older.
      "skills" # No Nix package.
      "vsce" # No Nix package.
    ];

    casks = [
      "1password-cli" # Nix package is marked as broken.
      "1password" # Nix package is marked as broken.
      "autodesk-fusion" # No nix package.
      "betterdisplay" # No nix package (macOS specific).
      "brave-browser" # No nix package.
      "coscreen" # No Nix package.
      "docker-desktop" # Docker Desktop
      "dropbox"
      "font-monaspace"
      "ghostty" # Nix package is marked as broken on Darwin
      "inkscape" # Nix package crashes.
      "linear-linear" # No nix package.
      "slack" # Nix package didn't allow loading slack:// links from Safari
    ];
  };

  # Install App Store apps as the primary user via launchctl asuser so mas can
  # reach the App Store daemon (which is tied to the user's launchd session).
  system.activationScripts.masApps.text =
    let
      user = config.system.primaryUser;
      mas = "${pkgs.mas}/bin/mas";
      installs = builtins.concatStringsSep "\n" (
        builtins.attrValues (
          builtins.mapAttrs (name: id: ''
            if /bin/launchctl asuser "$uid" /usr/bin/sudo -u ${user} ${mas} list | grep -q '^${toString id}\b'; then
              echo "mas: ${name} already installed"
            else
              echo "mas: installing ${name} (${toString id})"
              /bin/launchctl asuser "$uid" /usr/bin/sudo -u ${user} ${mas} install ${toString id} \
                || echo "mas: warning: failed to install ${name}"
            fi
          '') masApps
        )
      );
    in
    ''
      uid=$(id -u ${user} 2>/dev/null) || { echo "mas: user ${user} not found, skipping"; exit 0; }
      ${installs}
    '';
}

