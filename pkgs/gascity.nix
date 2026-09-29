{ lib, stdenvNoCC, fetchurl }:

let
  version = "1.4.2";
  assets = {
    aarch64-darwin = {
      url = "https://github.com/gastownhall/gascity/releases/download/v${version}/gascity_${version}_darwin_arm64.tar.gz";
      hash = "sha256-E+czJ1R0Ju24nz1cc5dbRW3cfG8zNq5zsswXdhr1O0w=";
    };
    x86_64-darwin = {
      url = "https://github.com/gastownhall/gascity/releases/download/v${version}/gascity_${version}_darwin_amd64.tar.gz";
      hash = "sha256-C6IWTok1vDfMdW7wKPPy3Yq3iy2hBLNjcnZrJPNuFh4=";
    };
  };
  asset = assets.${stdenvNoCC.hostPlatform.system}
    or (throw "gascity: unsupported system ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation {
  pname = "gascity";
  inherit version;

  src = fetchurl {
    inherit (asset) url hash;
  };

  sourceRoot = ".";

  installPhase = ''
    install -Dm755 gc $out/bin/gc
  '';

  meta = {
    description = "Gas City: tmux/dolt-backed dev environment supervisor (gc CLI)";
    homepage = "https://github.com/gastownhall/gascity";
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
    mainProgram = "gc";
  };
}
