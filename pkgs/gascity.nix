{ lib, stdenvNoCC, fetchurl }:

let
  version = "1.0.0";
  assets = {
    aarch64-darwin = {
      url = "https://github.com/gastownhall/gascity/releases/download/v${version}/gascity_${version}_darwin_arm64.tar.gz";
      hash = "sha256-S2zb/9UotLKYUQj82OIS0m3s7uzHjkso+VoJx+MJFFk=";
    };
    x86_64-darwin = {
      url = "https://github.com/gastownhall/gascity/releases/download/v${version}/gascity_${version}_darwin_amd64.tar.gz";
      hash = "sha256-1051hj7RacC12/a2X5My980BbbEyEcyKQ4+A57glMZw=";
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
