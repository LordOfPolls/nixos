{ config, pkgs, lib, ... }:

{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;

    dotDir = "${config.xdg.configHome}/zsh";

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [ "git" ];
    };

    shellAliases = {
      cat = "bat --paging=never";
      ls = "eza";
      ll = "eza -lah --git";
      lt = "eza --tree --level=2";
      find = "fd";
      grep = "rg";
      du = "dust";
      ps = "procs";
      top = "btm";
      sed = "sd";
      help = "tldr";
      cd = "z";
    };

    initContent = ''
      eval "$(zoxide init zsh)"

      # Android SDK
      export ANDROID_HOME=$HOME/Android/Sdk
      export PATH=$PATH:$ANDROID_HOME/emulator
      export PATH=$PATH:$ANDROID_HOME/platform-tools
      export PATH=$PATH:$ANDROID_HOME/tools/bin
    '';
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.kitty = {
    enable = true;
  };

  programs.alacritty.enable = true;

  home.packages = with pkgs; [
    fd
    ripgrep
    dust
    procs
    bottom
    sd
    tldr
    duf
    fastfetch
  ];

  programs.bat = {
    enable = true;
  };

  programs.eza = {
    enable = true;
    enableZshIntegration = false;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = false;
  };

  programs.git = {
    enable = true;
    settings.user.name = "LordOfPolls";
    settings.user.email = "dev@lordofpolls.com";
    extraConfig.credential.helper = "${pkgs.git.override { withLibsecret = true; }}/bin/git-credential-libsecret";
  };
}
