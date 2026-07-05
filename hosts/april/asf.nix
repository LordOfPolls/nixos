{...}: {
  services.archisteamfarm = {
    enable = true;

    # Web IPC UI available at http://localhost:1242
    # Set a password: echo -n "yourpassword" > /var/lib/archisteamfarm/ipc-password
    # then chown archisteamfarm:archisteamfarm it
    ipcPasswordFile = "/var/lib/archisteamfarm/ipc-password";

    web-ui.enable = true;

    # Add bots here. passwordFile must be a path outside the nix store.
    # To create one: echo -n "your-steam-password" > /var/lib/archisteamfarm/secrets/botname
    # then chown archisteamfarm:archisteamfarm it
    bots = {
       #example = {
       #  username = "your-steam-username";
       #  passwordFile = "/var/lib/archisteamfarm/secrets/example";
      # };
    };
  };
}
