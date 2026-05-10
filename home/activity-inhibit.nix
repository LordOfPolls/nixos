{pkgs, ...}: let
  script =
    pkgs.writeShellScriptBin "activity-inhibit"
    (builtins.readFile ./scripts/activity-inhibit.sh);
in {
  home.packages = [script];

  systemd.user.services.activity-inhibit = {
    Unit = {
      Description = "Inhibit sleep during CPU/GPU/network activity";
      After = ["graphical-session.target"];
      PartOf = ["graphical-session.target"];
    };
    Service = {
      Type = "simple";
      ExecStart = "${script}/bin/activity-inhibit";
      Restart = "on-failure";
      RestartSec = "5s";
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };
}
