{
  config,
  pkgs,
  lib,
  savepoint,
  ...
}: {
  imports = [
    ./hyprland.nix
    ./shell.nix
    ./dev
    ./theme.nix
    ./gaming.nix
    ./zen.nix
    ./activity-inhibit.nix
  ];

  home = {
    username = "polls";
    homeDirectory = "/home/polls";
    stateVersion = "25.11";
  };

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    chromium

    nemo-with-extensions

    vlc
    strawberry
    obs-studio

    onlyoffice-desktopeditors

    vesktop

    orca-slicer

    meld
    file-roller
    mousepad
    pavucontrol
    pwvucontrol

    glances
    nwg-displays

    profile-sync-daemon

    guvcview

    gimp
    evince

    qalculate-gtk
    gnome-disk-utility
    timeshift

    satty
  ];

  services.psd = {
    enable = true;
  };

  home.file.".local/bin/wg-toggle.sh" = {
    source = ./scripts/wg-toggle.sh;
    executable = true;
  };

  xdg.enable = true;
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    setSessionVariables = false;
  };
}
