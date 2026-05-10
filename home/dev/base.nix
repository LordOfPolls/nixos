{ config, pkgs, lib, savepoint, ... }:

{
  home.packages = with pkgs; [
    micro
    vim

    gitkraken

    pre-commit
    pkgs.convco

    jq
    htop
    btop

    savepoint.packages.${pkgs.system}.default
  ];

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
