{ pkgs, userConfig, ... }:

let
  inherit (userConfig) home;
in
{
  launchd.user.agents.colima = {
    serviceConfig = {
      ProgramArguments = [
        "${pkgs.colima}/bin/colima"
        "start"
        "--foreground"
        "--runtime" "incus"
        "--cpu"     "4"
        "--memory"  "8"
        "--disk"    "100"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      ThrottleInterval = 30;
      StandardOutPath = "${home}/Library/Logs/colima.log";
      StandardErrorPath = "${home}/Library/Logs/colima.log";
      EnvironmentVariables = {
        # colima shells out to docker/lima/qemu — make sure the nix profile is on PATH
        # /opt/homebrew/bin needed for the incus client (brew-only; nixpkgs incus is Linux-only)
        PATH = "/run/current-system/sw/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin";
        HOME = home;
      };
    };
  };

  launchd.user.agents.colima-docker = {
    serviceConfig = {
      ProgramArguments = [
        "${pkgs.colima}/bin/colima"
        "start"
        "--foreground"
        "--profile" "docker"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      ThrottleInterval = 30;
      StandardOutPath = "${home}/Library/Logs/colima-docker.log";
      StandardErrorPath = "${home}/Library/Logs/colima-docker.log";
      EnvironmentVariables = {
        PATH = "/run/current-system/sw/bin:/usr/bin:/bin:/usr/sbin:/sbin";
        HOME = home;
      };
    };
  };
}
