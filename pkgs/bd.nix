{ lib, stdenvNoCC, fetchurl }:

let
  version = "1.3.0";
  assets = {
    aarch64-darwin = {
      url = "https://github.com/gastownhall/beads/releases/download/v${version}/beads_${version}_darwin_arm64.tar.gz";
      hash = "sha256-fMdzZ9C4TFAkOhEIvB9zZIaZIRJX1BS5F1QL+Gjmu4U=";
    };
    x86_64-darwin = {
      url = "https://github.com/gastownhall/beads/releases/download/v${version}/beads_${version}_darwin_amd64.tar.gz";
      hash = "sha256-39imkYvCpYoNvHJ/fkA5dm4yPfoV5MyrJQ1kCFHikNU=";
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
    homepage = "https://github.com/gastownhall/beads";
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
    mainProgram = "bd";
  };
}
