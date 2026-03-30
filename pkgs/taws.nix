{ lib, stdenvNoCC, fetchurl }:

let
  version = "1.3.0-rc.7";
  assets = {
    aarch64-darwin = {
      url = "https://github.com/huseyinbabal/taws/releases/download/v${version}/taws-aarch64-apple-darwin.tar.gz";
      hash = "sha256-haYI2J2DDDYBkN/m5+SWhLlMzTvbzgBqmXwjadBiPs8=";
    };
    x86_64-darwin = {
      url = "https://github.com/huseyinbabal/taws/releases/download/v${version}/taws-x86_64-apple-darwin.tar.gz";
      hash = "sha256-SSJC4VURecjXsBJkHzgVa0yDp5xbsMfYfS4SKmjJlEk=";
    };
  };
  asset = assets.${stdenvNoCC.hostPlatform.system}
    or (throw "taws: unsupported system ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation {
  pname = "taws";
  inherit version;

  src = fetchurl {
    inherit (asset) url hash;
  };

  sourceRoot = ".";

  installPhase = ''
    install -Dm755 taws $out/bin/taws
  '';

  meta = {
    description = "Terminal UI for AWS";
    homepage = "https://github.com/huseyinbabal/taws";
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
    mainProgram = "taws";
  };
}
