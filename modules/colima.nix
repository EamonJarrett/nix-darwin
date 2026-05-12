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
        "--cpu"     "4"
        "--memory"  "8"
        "--disk"    "60"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      ThrottleInterval = 30;
      StandardOutPath = "${home}/Library/Logs/colima.log";
      StandardErrorPath = "${home}/Library/Logs/colima.log";
      EnvironmentVariables = {
        # colima shells out to docker/lima/qemu — make sure the nix profile is on PATH
        PATH = "/run/current-system/sw/bin:/usr/bin:/bin:/usr/sbin:/sbin";
        HOME = home;
      };
    };
  };
}
