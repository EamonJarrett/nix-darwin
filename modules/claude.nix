{ pkgs, lib, ... }:

let
  user = "eamon";
  home = "/Users/${user}";
  claudeDir = "${home}/.claude";
  repoDir = "${home}/.config/nix-darwin/.claude";

  # Static files symlinked from repo → ~/.claude/.
  # settings.json and settings.local.json stay mutable so Claude Code can edit them.
  files = {
    "CLAUDE.md"             = "CLAUDE.md";
    "RTK.md"                = "RTK.md";
    "hooks/rtk-rewrite.sh"  = "hooks/rtk-rewrite.sh";
  };

  linkLines = lib.concatStringsSep "\n" (lib.mapAttrsToList (dest: src: ''
    mkdir -p "$(dirname "${claudeDir}/${dest}")"
    ln -sfn "${repoDir}/${src}" "${claudeDir}/${dest}"
  '') files);

  syncScript = pkgs.writeShellScript "claude-sync" ''
    set -eu
    ${linkLines}
  '';
in
{
  system.activationScripts.postActivation.text = lib.mkAfter ''
    echo "[claude] syncing config symlinks → ${repoDir}"
    /usr/bin/sudo -u ${user} ${syncScript}
  '';
}
