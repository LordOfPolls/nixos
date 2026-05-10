{ config, pkgs, lib, ... }:

{
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
    gtk4.theme = config.gtk.theme;
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "Adwaita-dark";
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "qt6ct";
    style.name = "Fusion";
  };

  home.packages = with pkgs; [
    qt6Packages.qt6ct
    nwg-look
    cava
    dconf
  ];

  xdg.configFile."qt6ct/qt6ct.conf".text = ''
    [Appearance]
    color_scheme_path=${pkgs.qt6Packages.qt6ct}/share/qt6ct/colors/darker.conf
    custom_palette=true
    standard_dialogs=gtk3
    style=Fusion

    [Fonts]
    fixed="DejaVu LGC Sans,12,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"
    general="DejaVu LGC Sans,12,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"

    [Interface]
    activate_item_on_single_click=1
    buttonbox_layout=0
    cursor_flash_time=1000
    dialog_buttons_have_icons=1
    double_click_interval=400
    gui_effects=@Invalid()
    keyboard_scheme=2
    menus_have_icons=true
    show_shortcuts_in_context_menus=true
  '';

  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 24;
    gtk.enable = true;
  };

  xdg.configFile."cava/config".source = ./configs/cava-config;
}
