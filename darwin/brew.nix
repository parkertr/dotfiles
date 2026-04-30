{ pkgs, ... }:
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

    masApps = {
      "magnet" = 441258766;
      "xcode" = 497799835;
    };
  };
}
