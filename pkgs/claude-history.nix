{ lib, stdenvNoCC, fetchurl }:

let
  version = "0.1.76";
  assets = {
    aarch64-darwin = {
      url = "https://github.com/raine/claude-history/releases/download/v${version}/claude-history-darwin-arm64.tar.gz";
      hash = "sha256-7Zc924Mk3a2LLnBzoz/p99/o8tH3kzzZIdh+xe8R544=";
    };
    x86_64-darwin = {
      url = "https://github.com/raine/claude-history/releases/download/v${version}/claude-history-darwin-amd64.tar.gz";
      hash = "sha256-Mn98lYNdaVpYsCBqqn56XA+nACqads4GIhdTYm1/MM4=";
    };
  };
  asset = assets.${stdenvNoCC.hostPlatform.system}
    or (throw "claude-history: unsupported system ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation {
  pname = "claude-history";
  inherit version;

  src = fetchurl {
    inherit (asset) url hash;
  };

  sourceRoot = ".";

  installPhase = ''
    install -Dm755 claude-history $out/bin/claude-history
  '';

  meta = {
    description = "Fuzzy-search Claude Code conversation history TUI";
    homepage = "https://github.com/raine/claude-history";
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
    mainProgram = "claude-history";
  };
}
