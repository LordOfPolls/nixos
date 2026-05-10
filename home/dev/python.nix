{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    python3
    pyenv
    uv
    ruff

    jetbrains.pycharm

    playwright
  ];

  home.file."PycharmProjects".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Projects";
}
