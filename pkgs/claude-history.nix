{ lib, stdenvNoCC, fetchurl }:

let
  version = "0.1.51";
  assets = {
    aarch64-darwin = {
      url = "https://github.com/raine/claude-history/releases/download/v${version}/claude-history-darwin-arm64.tar.gz";
      hash = "sha256-S71wAeGRCYItjX/zERiX0DWsaiYZHSLiYjduzlxK6dg=";
    };
    x86_64-darwin = {
      url = "https://github.com/raine/claude-history/releases/download/v${version}/claude-history-darwin-amd64.tar.gz";
      hash = "sha256-aAoegUxbg04tjVl0/dFNXE+Wr2EJLC5E+ECZZY48ZDE=";
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
