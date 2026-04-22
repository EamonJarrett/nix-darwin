{ pkgs, lib, caveman-src, ... }:

let
  user = "eamon";
  home = "/Users/${user}";
  marketplaceLink = "${home}/.claude/plugins/marketplaces/caveman";
  knownFile = "${home}/.claude/plugins/known_marketplaces.json";

  syncScript = pkgs.writeShellScript "caveman-sync" ''
    set -eu
    mkdir -p "$(dirname ${marketplaceLink})"

    # Point marketplace at the current nix store path.
    if [ -L ${marketplaceLink} ] || [ -e ${marketplaceLink} ]; then
      rm -rf ${marketplaceLink}
    fi
    ln -s ${caveman-src} ${marketplaceLink}

    # Register the marketplace in known_marketplaces.json (idempotent).
    [ -f ${knownFile} ] || echo '{}' > ${knownFile}
    ${pkgs.jq}/bin/jq \
      --arg loc "${marketplaceLink}" \
      --arg ts "$(${pkgs.coreutils}/bin/date -u +%Y-%m-%dT%H:%M:%S.000Z)" \
      '. + {caveman: {source: {source: "github", repo: "JuliusBrussee/caveman"}, installLocation: $loc, lastUpdated: $ts}}' \
      ${knownFile} > ${knownFile}.tmp
    mv ${knownFile}.tmp ${knownFile}
  '';
in
{
  system.activationScripts.postActivation.text = lib.mkAfter ''
    echo "[caveman] syncing marketplace → ${caveman-src}"
    /usr/bin/sudo -u ${user} ${syncScript}
    echo "[caveman] done. First time? Run /plugin install caveman@caveman in Claude Code."
  '';
}
