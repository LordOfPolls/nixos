{
  config,
  pkgs,
  lib,
  ...
}: {
  home.packages = with pkgs; [
    protonup-qt

    bottles

    mangohud

    gpu-screen-recorder
    gpu-screen-recorder-gtk
  ];

  xdg.configFile."MangoHud/MangoHud.conf".text = ''
    # MangoHud minimal overlay — toggle with Shift+F12
    fps
    frametime
    gpu_stats
    cpu_stats
    vram
    ram=0
  '';
}
