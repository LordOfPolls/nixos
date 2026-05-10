{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    rustup
    bacon

    jetbrains.rust-rover
  ];

  home.file."RustRoverProjects".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Projects";
}
