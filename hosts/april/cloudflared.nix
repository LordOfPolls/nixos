{...}: {
  services.cloudflared = {
    enable = true;
    tunnels."ae8db5ea-8576-4d0d-9369-58c46980a8bd" = {
      credentialsFile = "/etc/nixos/secrets/cloudflared-tunnel.json";
      ingress."april-ssh.lordofpolls.com" = {
        service = "ssh://localhost:22";
      };
      default = "http_status:404";
    };
  };
}
