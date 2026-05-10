{ config, pkgs, lib, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;

    # Using extraConfig rather than settings because the config uses newer
    # v0.54+ windowrule syntax with name/match blocks that don't map cleanly
    # to the nix attrset format.
    extraConfig = ''
      ################
      ### MONITORS ###
      ################
      # Adjust these after install — hwmon paths and monitor descriptions will differ
      monitor=desc:Dell Inc. DELL S3422DWG 8RQXS63,3440x1440@59.97,1980x597,1.0,bitdepth,10
      monitor=desc:Dell Inc. DELL U2520D H48W823,2560x1440@59.95,540x0,1.0
      monitor=desc:Dell Inc. DELL U2520D H48W823,transform,3

      ###################
      ### MY PROGRAMS ###
      ###################
      $terminal = kitty
      $fileManager = nemo
      $menu = hyprlauncher

      #################
      ### AUTOSTART ###
      #################
      exec-once = hyprlock
      exec-once = systemctl --user start hyprpolkitagent
      exec-once = ~/.config/waybar/launch.sh
      exec-once = hyprpaper
      exec-once = hypridle
      exec-once = swayosd-server
      exec-once = dunst
      exec-once = wl-paste --type text --watch cliphist store
      exec-once = wl-paste --type image --watch cliphist store
      exec-once = nm-applet --indicator
      exec-once = blueman-applet
      exec-once = [workspace special:magic silent] $terminal

      #############################
      ### ENVIRONMENT VARIABLES ###
      #############################
      env = XCURSOR_SIZE,24
      env = HYPRCURSOR_SIZE,24
      env = GTK_THEME,Adwaita:dark
      env = ADW_DEBUG_COLOR_SCHEME,prefer-dark
      env = QT_QPA_PLATFORMTHEME,qt6ct

      #####################
      ### LOOK AND FEEL ###
      #####################
      decoration {
          rounding = 10
          rounding_power = 2
          active_opacity = 1.0
          inactive_opacity = 1.0

          shadow {
              enabled = true
              range = 4
              render_power = 3
              color = rgba(1a1a1aee)
          }

          blur {
              enabled = true
              size = 3
              passes = 1
              vibrancy = 0.1696
          }
      }

      animations {
          enabled = yes, please :)

          bezier = easeOutQuint,   0.23, 1,    0.32, 1
          bezier = easeInOutCubic, 0.65, 0.05, 0.36, 1
          bezier = linear,         0,    0,    1,    1
          bezier = almostLinear,   0.5,  0.5,  0.75, 1
          bezier = quick,          0.15, 0,    0.1,  1

          animation = global,        1,     10,    default
          animation = border,        1,     5.39,  easeOutQuint
          animation = windows,       1,     4.79,  easeOutQuint
          animation = windowsIn,     1,     4.1,   easeOutQuint, popin 87%
          animation = windowsOut,    1,     1.49,  linear,       popin 87%
          animation = fadeIn,        1,     1.73,  almostLinear
          animation = fadeOut,       1,     1.46,  almostLinear
          animation = fade,          1,     3.03,  quick
          animation = layers,        1,     3.81,  easeOutQuint
          animation = layersIn,      1,     4,     easeOutQuint, fade
          animation = layersOut,     1,     1.5,   linear,       fade
          animation = fadeLayersIn,  1,     1.79,  almostLinear
          animation = fadeLayersOut, 1,     1.39,  almostLinear
          animation = workspaces,    1,     1.94,  almostLinear, fade
          animation = workspacesIn,  1,     1.21,  almostLinear, fade
          animation = workspacesOut, 1,     1.94,  almostLinear, fade
          animation = zoomFactor,    1,     7,     quick
      }

      exec-once = gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
      exec-once = gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"

      # Smart gaps
      workspace = w[tv1], gapsout:0, gapsin:0
      workspace = f[1], gapsout:0, gapsin:0
      windowrule {
          name = no-gaps-wtv1
          match:float = false
          match:workspace = w[tv1]
          border_size = 0
          rounding = 0
      }
      windowrule {
          name = no-gaps-f1
          match:float = false
          match:workspace = f[1]
          border_size = 0
          rounding = 0
      }

      dwindle {
          pseudotile = true
          preserve_split = true
      }

      master {
          new_status = master
      }

      misc {
          force_default_wallpaper = 0
          disable_hyprland_logo = true
      }

      #############
      ### INPUT ###
      #############
      input {
          kb_layout = gb
          follow_mouse = 1
          sensitivity = 0
          touchpad {
              natural_scroll = false
          }
      }

      gesture = 3, horizontal, workspace

      ###################
      ### KEYBINDINGS ###
      ###################
      $mainMod = SUPER

      bind = $mainMod, T, exec, $terminal
      bind = $mainMod, Q, killactive,
      bind = $mainMod, M, exit,
      bind = $mainMod, E, exec, $fileManager
      bind = $mainMod, V, exec, cliphist list | wofi --dmenu --prompt "Clipboard" | cliphist decode | wl-copy
      bind = $mainMod, F, fullscreen, 0
      bind = $mainMod SHIFT, F, togglefloating,
      bind = $mainMod, R, exec, $menu
      bind = $mainMod, P, pseudo,
      bind = $mainMod, J, togglesplit,
      bind = $mainMod, B, exec, zen-beta
      bind = $mainMod, C, exec, hyprpicker -a
      bind = $mainMod, L, exec, hyprlock
      bind = $mainMod, period, exec, bemoji -t -n
      bind = $mainMod, A, exec, pwvucontrol

      # Screenshots — grim + slurp + satty
      $screenshotDir = $HOME/Pictures/Screenshots
      bind = , Print, exec, mkdir -p $screenshotDir && grim -g "$(slurp -o)" - | satty --filename - --output-filename $screenshotDir/scr-$(date +%Y%m%d-%H%M%S).png --early-exit --copy-command wl-copy
      bind = SHIFT, Print, exec, mkdir -p $screenshotDir && grim -g "$(slurp)" - | satty --filename - --output-filename $screenshotDir/scr-$(date +%Y%m%d-%H%M%S).png --early-exit --copy-command wl-copy
      bind = $mainMod, Print, exec, mkdir -p $screenshotDir && grim - | satty --filename - --output-filename $screenshotDir/scr-$(date +%Y%m%d-%H%M%S).png --early-exit --copy-command wl-copy
      bind = $mainMod SHIFT, Print, exec, mkdir -p $screenshotDir && grim -g "$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')" - | satty --filename - --output-filename $screenshotDir/scr-$(date +%Y%m%d-%H%M%S).png --early-exit --copy-command wl-copy

      # Focus
      bind = $mainMod, left, movefocus, l
      bind = $mainMod, right, movefocus, r
      bind = $mainMod, up, movefocus, u
      bind = $mainMod, down, movefocus, d

      # Move windows
      bind = $mainMod SHIFT, left, movewindow, l
      bind = $mainMod SHIFT, right, movewindow, r
      bind = $mainMod SHIFT, up, movewindow, u
      bind = $mainMod SHIFT, down, movewindow, d

      # Groups
      bind = $mainMod, G, togglegroup,
      bind = $mainMod, TAB, changegroupactive, f

      # Workspaces
      bind = $mainMod, 1, workspace, 1
      bind = $mainMod, 2, workspace, 2
      bind = $mainMod, 3, workspace, 3
      bind = $mainMod, 4, workspace, 4
      bind = $mainMod, 5, workspace, 5
      bind = $mainMod, 6, workspace, 6
      bind = $mainMod, 7, workspace, 7
      bind = $mainMod, 8, workspace, 8
      bind = $mainMod, 9, workspace, 9
      bind = $mainMod, 0, workspace, 10

      bind = $mainMod SHIFT, 1, movetoworkspace, 1
      bind = $mainMod SHIFT, 2, movetoworkspace, 2
      bind = $mainMod SHIFT, 3, movetoworkspace, 3
      bind = $mainMod SHIFT, 4, movetoworkspace, 4
      bind = $mainMod SHIFT, 5, movetoworkspace, 5
      bind = $mainMod SHIFT, 6, movetoworkspace, 6
      bind = $mainMod SHIFT, 7, movetoworkspace, 7
      bind = $mainMod SHIFT, 8, movetoworkspace, 8
      bind = $mainMod SHIFT, 9, movetoworkspace, 9
      bind = $mainMod SHIFT, 0, movetoworkspace, 10

      # Scratchpad
      bind = $mainMod, S, togglespecialworkspace, magic
      bind = $mainMod SHIFT, S, movetoworkspace, special:magic

      # Mouse
      bind = $mainMod, mouse_down, workspace, e+1
      bind = $mainMod, mouse_up, workspace, e-1
      bindm = $mainMod, mouse:272, movewindow
      bindm = $mainMod, mouse:273, resizewindow

      # Resize with keyboard
      binde = $mainMod ALT, left, resizeactive, -20 0
      binde = $mainMod ALT, right, resizeactive, 20 0
      binde = $mainMod ALT, up, resizeactive, 0 -20
      binde = $mainMod ALT, down, resizeactive, 0 20
      binde = $mainMod ALT, H, resizeactive, -20 0
      binde = $mainMod ALT, L, resizeactive, 20 0
      binde = $mainMod ALT, K, resizeactive, 0 -20
      binde = $mainMod ALT, J, resizeactive, 0 20

      # Replay save
      bind = $mainMod SHIFT, R, exec, gpu-screen-recorder-ctl save-replay

      # Resize submap
      bind = $mainMod CTRL, R, submap, resize
      submap = resize
      binde = , left, resizeactive, -20 0
      binde = , right, resizeactive, 20 0
      binde = , up, resizeactive, 0 -20
      binde = , down, resizeactive, 0 20
      binde = , H, resizeactive, -20 0
      binde = , L, resizeactive, 20 0
      binde = , K, resizeactive, 0 -20
      binde = , J, resizeactive, 0 20
      bind = , escape, submap, reset
      bind = , return, submap, reset
      submap = reset

      # Media keys
      bindel = ,XF86AudioRaiseVolume, exec, swayosd-client --output-volume raise
      bindel = ,XF86AudioLowerVolume, exec, swayosd-client --output-volume lower
      bindel = ,XF86AudioMute, exec, swayosd-client --output-volume mute-toggle
      bindel = ,XF86AudioMicMute, exec, swayosd-client --input-volume mute-toggle
      bindel = ,XF86MonBrightnessUp, exec, swayosd-client --brightness raise
      bindel = ,XF86MonBrightnessDown, exec, swayosd-client --brightness lower
      bindl = , XF86AudioNext, exec, playerctl next
      bindl = , XF86AudioPause, exec, playerctl play-pause
      bindl = , XF86AudioPlay, exec, playerctl play-pause
      bindl = , XF86AudioPrev, exec, playerctl previous

      ##############################
      ### WINDOWS AND WORKSPACES ###
      ##############################
      windowrule {
          name = suppress-maximize-events
          match:class = .*
          suppress_event = maximize
      }
      windowrule {
          name = fix-xwayland-drags
          match:class = ^$
          match:title = ^$
          match:xwayland = true
          match:float = true
          match:fullscreen = false
          match:pin = false
          no_focus = true
      }

      # Dracula-ish border colors
      general {
          col.active_border = rgb(7aa2d4) rgb(1a1d2a) 90deg
          col.inactive_border = rgba(5a607066)
          col.nogroup_border = rgba(12141edd)
          col.nogroup_border_active = rgb(7aa2d4) rgb(1a1d2a) 90deg
          border_size = 2
      }

      decoration:shadow {
          color = rgba(05081266)
      }

      group {
          groupbar {
              col.active = rgb(7aa2d4) rgb(1a1d2a) 90deg
              col.inactive = rgba(12141edd)
          }
      }

      # Float rules
      windowrule {
          name = float-nemo
          match:class = nemo
          float = true
          size = 900 600
          center = true
      }
      windowrule {
          name = float-pwvucontrol
          match:class = pwvucontrol
          float = true
          size = 800 600
          center = true
      }
      windowrule {
          name = float-blueman
          match:class = blueman-manager
          float = true
          size = 600 500
          center = true
      }
      windowrule {
          name = pip
          match:title = ^(Picture(-| )in(-| )[Pp]icture)$
          float = true
          pin = true
          move = 69% 72%
          size = 30% 30%
      }
    '';
  };

  home.packages = with pkgs; [
    hyprpaper
    hypridle
    hyprlock
    hyprpicker
    hyprlauncher
    hyprpolkitagent
    swayosd

    dunst
    wofi
    cliphist
    bemoji
    networkmanagerapplet

    # Keybinding runtime deps
    grim
    slurp
    playerctl
    wl-clipboard
    brightnessctl
  ];

  xdg.configFile."hypr/hypridle.conf".text = ''
    general {
        lock_cmd = pidof hyprlock || hyprlock
        before_sleep_cmd = loginctl lock-session
        after_sleep_cmd = hyprctl dispatch dpms on
    }

    # Dim at 4 min
    listener {
        timeout = 240
        on-timeout = brightnessctl -s set 10
        on-resume = brightnessctl -r
    }

    # Lock at 5 min
    listener {
        timeout = 300
        on-timeout = loginctl lock-session
    }

    # Screen off at 6 min
    listener {
        timeout = 360
        on-timeout = hyprctl dispatch dpms off
        on-resume = hyprctl dispatch dpms on
    }

    # Suspend at 20 min
    listener {
        timeout = 1200
        on-timeout = systemctl suspend
    }
  '';

  xdg.configFile."hypr/dracula_colors.conf".text = ''
    $background = rgb(282A36)
    $backgroundRaw = 282A36
    $foreground = rgb(F8F8F2)
    $foregroundRaw = F8F8F2
    $selection = rgb(44475A)
    $selectionRaw = 44475A
    $comment = rgb(6272A4)
    $commentRaw = 6272A4
    $red = rgb(FF5555)
    $redRaw = FF5555
    $orange = rgb(FFB86C)
    $orangeRaw = FFB86C
    $yellow = rgb(F1FA8C)
    $yellowRaw = F1FA8C
    $green = rgb(50FA7B)
    $greenRaw = 50FA7B
    $purple = rgb(BD93F9)
    $purpleRaw = BD93F9
    $cyan = rgb(8BE9FD)
    $cyanRaw = 8BE9FD
    $pink = rgb(FF79C6)
    $pinkRaw = FF79C6
    $accent = $purple
    $accentRaw = $purpleRaw
  '';

  xdg.configFile."hypr/hyprlock.conf".text = ''
    general {
        hide_cursor = true
    }

    background {
        monitor =
        color = rgb(000000)
        blur_passes = 0
    }

    input-field {
        monitor =
        size = 400, 80
        outline_thickness = 2000
        dots_size = 0.4
        dots_spacing = 0.2
        dots_center = true
        dots_text_format = *
        rounding = 0
        outer_color = rgba(00000000)
        inner_color = rgb(000000)
        font_color = rgb(ffffff)
        font_family = JetBrainsMono Nerd Font
        fade_on_empty = false
        placeholder_text =
        check_color = rgba(00000000)
        fail_color = rgba(cc000099)
        fail_text =
        fail_transition = 300
        position = 0, 0
        halign = center
        valign = center
    }
  '';

  xdg.configFile."hypr/hyprpaper.conf".text = ''
    wallpaper {
        monitor =
        path = ${config.home.homeDirectory}/Pictures/moon-peekaboo.jpeg
    }
    splash = false
    ipc = on
  '';

  programs.waybar = {
    enable = true;
    # Use config file directly — the JSON has template strings that
    # don't survive nix attrset round-tripping cleanly
  };

  xdg.configFile."waybar/config".source = ./configs/waybar-config.json;
  xdg.configFile."waybar/style.css".source = ./configs/waybar-style.css;
  xdg.configFile."waybar/launch.sh" = {
    text = ''
      #!/usr/bin/env bash
      killall waybar 2>/dev/null
      waybar
    '';
    executable = true;
  };

  services.dunst = {
    enable = true;
    settings = {
      global = {
        width = 350;
        offset = "10x10";
        origin = "top-right";
        follow = "mouse";
        transparency = 0;
        frame_color = "#7aa2d4";
        font = "JetBrainsMono Nerd Font 10";
        corner_radius = 10;
      };
      urgency_low = {
        background = "#1a1d2a";
        foreground = "#c8ccd4";
      };
      urgency_normal = {
        background = "#1a1d2a";
        foreground = "#c8ccd4";
      };
      urgency_critical = {
        background = "#1a1d2a";
        foreground = "#c45a5a";
        frame_color = "#c45a5a";
      };
    };
  };
}
