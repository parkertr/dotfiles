{ pkgs, ... }:
{
  home = {
    packages = [ pkgs.cursor ];

    shellAliases = {
      c = "cursor .";
    };
  };
}
