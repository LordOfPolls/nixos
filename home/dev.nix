{ config, pkgs, lib, savepoint, ... }:

let
  dotnetCombined = pkgs.dotnetCorePackages.combinePackages [
    pkgs.dotnet-sdk_8
    pkgs.dotnet-sdk_9
    pkgs.dotnet-sdk_10
  ];
in
{
  home.packages = with pkgs; [
    micro
    vim

    python3
    pyenv
    uv
    ruff

    rustup
    bacon

    go

    nodejs
    pnpm

    dotnetCombined

    jdk17

    cmake
    gnumake
    gcc

    pgadmin4

    docker-compose
    minikube

    gitkraken

    jetbrains.pycharm
    jetbrains.rust-rover
    jetbrains.rider
    jetbrains.datagrip

    sqlx-cli
    pre-commit
    playwright
    pkgs.convco

    arduino-ide

    jq
    htop
    btop

    savepoint.packages.${pkgs.system}.default
  ];

  home.sessionVariables = {
    DOTNET_ROOT = "${dotnetCombined}";
  };

  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    argvSettings = {
      "password-store" = "gnome-libsecret";
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
  };

  home.activation.ensureProjectsDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/Projects"
  '';

  home.file = {
    "PycharmProjects".source    = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Projects";
    "RustRoverProjects".source  = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Projects";
    "RiderProjects".source      = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Projects";
    "DataGripProjects".source   = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Projects";
  };

  programs.git = {
    enable = true;
    ignores = [
      # AI / Claude
      ".claude"
      ".claude/"
      "claude.md"
      "CLAUDE.md"
      ".cursorrules"
      ".cursorignore"
      ".aider*"

      # JetBrains IDEs
      ".idea/"
      "*.iml"
      "*.ipr"
      "*.iws"

      # VS Code
      ".vscode/"
      "*.code-workspace"

      # macOS
      ".DS_Store"
      ".AppleDouble"
      ".LSOverride"

      # Linux
      "*~"
      ".fuse_hidden*"
      ".Trash-*"
      ".nfs*"

      # Logs & temp
      "*.log"
      "*.tmp"
      "*.bak"
      "*.swp"
      "*.swo"

      # Environment / secrets
      ".env"
      ".env.*"
      "!.env.example"

      # Node
      "node_modules/"

      # Python
      "__pycache__/"
      "*.py[cod]"
      ".venv/"
      ".mypy_cache/"
      ".ruff_cache/"

      # Rust
      "target/"

      # Nix
      "result"
      "result-*"
    ];
  };
}
