{ pkgs, ... }:

{
  home.packages = with pkgs; [
    cmake
    gnumake
    gcc

    arduino-ide
  ];
}
