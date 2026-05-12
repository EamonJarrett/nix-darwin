{ lib, stdenvNoCC, fetchurl }:

# Pinned override of nixpkgs dolt: gascity rejects Dolt < 1.86.2 because it
# misses the upstream GC/writer deadlock fix in dolthub/dolt commit ccf7bde206.
# Bump the version + hashes here when gascity raises its floor.
let
  version = "1.87.0";
  assets = {
    aarch64-darwin = {
      url = "https://github.com/dolthub/dolt/releases/download/v${version}/dolt-darwin-arm64.tar.gz";
      hash = "sha256-c1oI0la4gANLxTwg+cO0BJbyZrkIKtv7CngzbrdzNP8=";
      arch = "arm64";
    };
    x86_64-darwin = {
      url = "https://github.com/dolthub/dolt/releases/download/v${version}/dolt-darwin-amd64.tar.gz";
      hash = "sha256-YZfNn7uRD6jib5atzzlhzTcLbTiEN2YZ5MW2ywlhUn0=";
      arch = "amd64";
    };
  };
  asset = assets.${stdenvNoCC.hostPlatform.system}
    or (throw "dolt: unsupported system ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation {
  pname = "dolt";
  inherit version;

  src = fetchurl {
    inherit (asset) url hash;
  };

  sourceRoot = ".";

  installPhase = ''
    install -Dm755 dolt-darwin-${asset.arch}/bin/dolt $out/bin/dolt
  '';

  meta = {
    description = "Dolt: Git for data — SQL database with version control";
    homepage = "https://github.com/dolthub/dolt";
    license = lib.licenses.asl20;
    platforms = lib.platforms.darwin;
    mainProgram = "dolt";
  };
}
