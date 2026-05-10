{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    pgadmin4
    sqlx-cli

    jetbrains.datagrip
  ];

  home.file."DataGripProjects".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Projects";
}
