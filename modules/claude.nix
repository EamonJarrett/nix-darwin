{ pkgs, lib, userConfig, ... }:

let
  inherit (userConfig) user home;
  claudeDir = "${home}/.claude";
  repoDir = "${home}/.config/nix-darwin/.claude";

  # Static files symlinked from repo → ~/.claude/.
  # settings.json stays mutable for fields Claude Code edits (enabledPlugins, env);
  # the hooks block is force-managed below.
  files = {
    "CLAUDE.md"             = "CLAUDE.md";
    "RTK.md"                = "RTK.md";
    "hooks/rtk-rewrite.sh"  = "hooks/rtk-rewrite.sh";
  };

  linkLines = lib.concatStringsSep "\n" (lib.mapAttrsToList (dest: src: ''
    mkdir -p "$(dirname "${claudeDir}/${dest}")"
    ln -sfn "${repoDir}/${src}" "${claudeDir}/${dest}"
  '') files);

  # Canonical hook block. Managed here so the active PreToolUse hook always
  # matches the repo-tracked script (rtk-rewrite.sh).
  hookBlock = builtins.toJSON {
    PreToolUse = [{
      matcher = "Bash";
      hooks = [{
        type = "command";
        command = "${claudeDir}/hooks/rtk-rewrite.sh";
      }];
    }];
  };

  syncScript = pkgs.writeShellScript "claude-sync" ''
    set -eu
    ${linkLines}

    # Drop orphan hook from previous setup (settings now point at rtk-rewrite.sh).
    rm -f "${claudeDir}/hooks/rtk-with-bd.sh"

    # Merge managed hooks block into settings.json without clobbering other keys.
    settings="${claudeDir}/settings.json"
    if [ -f "$settings" ]; then
      ${pkgs.jq}/bin/jq --argjson hooks '${hookBlock}' '.hooks = $hooks' "$settings" > "$settings.tmp"
      mv "$settings.tmp" "$settings"
    else
      ${pkgs.jq}/bin/jq -n --argjson hooks '${hookBlock}' '{hooks: $hooks}' > "$settings"
    fi
  '';
in
{
  system.activationScripts.postActivation.text = lib.mkAfter ''
    echo "[claude] syncing config symlinks → ${repoDir}"
    /usr/bin/sudo -u ${user} ${syncScript}
  '';
}
