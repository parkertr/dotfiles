{ ... }:
{
  programs.brave = {
    enable = true;

    package = pkgs.brave;
    extensions = [
      { id = "aeblfdkhhhdcdjpifhhbdiojplfjncoa"; } # 1Password
    ];
  };
}
