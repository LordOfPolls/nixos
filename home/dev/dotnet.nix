{
  config,
  pkgs,
  ...
}: let
  dotnetCombined = pkgs.dotnetCorePackages.combinePackages [
    pkgs.dotnet-sdk_8
    pkgs.dotnet-sdk_9
    pkgs.dotnet-sdk_10
  ];
in {
  home.packages = with pkgs; [
    dotnetCombined

    jetbrains.rider
  ];

  home.sessionVariables = {
    DOTNET_ROOT = "${dotnetCombined}";
  };

  home.file."RiderProjects".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Projects";
}
