{ lib, stdenvNoCC, fetchurl }:

let
  version = "0.15.2";
  assets = {
    aarch64-darwin = {
      url = "https://github.com/Dicklesworthstone/beads_viewer/releases/download/v${version}/bv_${version}_darwin_arm64.tar.gz";
      hash = "sha256-Tt2XL7eLf4dZRD70iW0/6HQBb8dPrpcGszfZMixP4ss=";
    };
    x86_64-darwin = {
      url = "https://github.com/Dicklesworthstone/beads_viewer/releases/download/v${version}/bv_${version}_darwin_amd64.tar.gz";
      hash = "sha256-DR0YawziAZ32d2TQcannqgLNOQMs9qD2PPKcpKOG99I=";
    };
  };
  asset = assets.${stdenvNoCC.hostPlatform.system}
    or (throw "bv: unsupported system ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation {
  pname = "bv";
  inherit version;

  src = fetchurl {
    inherit (asset) url hash;
  };

  sourceRoot = ".";

  installPhase = ''
    install -Dm755 bv $out/bin/bv
  '';

  meta = {
    description = "Graph-aware task management TUI for beads projects";
    homepage = "https://github.com/Dicklesworthstone/beads_viewer";
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
    mainProgram = "bv";
  };
}
