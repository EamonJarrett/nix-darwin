{ lib, stdenvNoCC, fetchurl }:

let
  version = "0.62.0";
  assets = {
    aarch64-darwin = {
      url = "https://github.com/steveyegge/beads/releases/download/v${version}/beads_${version}_darwin_arm64.tar.gz";
      hash = "sha256-T0QcYWJAxwY6IlesJhONBurgYKlh8CnIGFWSjq5q4cA=";
    };
    x86_64-darwin = {
      url = "https://github.com/steveyegge/beads/releases/download/v${version}/beads_${version}_darwin_amd64.tar.gz";
      hash = "sha256-DDywCHRBIBCqPN8rbaEkckh+T1xSMVuvCHHKzL9FxeA=";
    };
  };
  asset = assets.${stdenvNoCC.hostPlatform.system}
    or (throw "bd: unsupported system ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation {
  pname = "bd";
  inherit version;

  src = fetchurl {
    inherit (asset) url hash;
  };

  sourceRoot = ".";

  installPhase = ''
    install -Dm755 bd $out/bin/bd
  '';

  meta = {
    description = "AI-supervised issue tracker for coding workflows";
    homepage = "https://github.com/steveyegge/beads";
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
    mainProgram = "bd";
  };
}
