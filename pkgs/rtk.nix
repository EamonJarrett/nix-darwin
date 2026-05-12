{ lib, stdenvNoCC, fetchurl }:

let
  version = "0.38.0";
  assets = {
    aarch64-darwin = {
      url = "https://github.com/rtk-ai/rtk/releases/download/v${version}/rtk-aarch64-apple-darwin.tar.gz";
      hash = "sha256-OJbIxD0CZB3arYjpGpVpIz815Ok4o794gmVtxzko+Xo=";
    };
    x86_64-darwin = {
      url = "https://github.com/rtk-ai/rtk/releases/download/v${version}/rtk-x86_64-apple-darwin.tar.gz";
      hash = "sha256-8Fv2JYI5iYz1dGf7BDeZUn6+PVJY6T8pD4TIt/QQ41k=";
    };
  };
  asset = assets.${stdenvNoCC.hostPlatform.system}
    or (throw "rtk: unsupported system ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation {
  pname = "rtk";
  inherit version;

  src = fetchurl {
    inherit (asset) url hash;
  };

  sourceRoot = ".";

  installPhase = ''
    install -Dm755 rtk $out/bin/rtk
  '';

  meta = {
    description = "Rust Token Killer: CLI proxy that compresses dev-tool output before LLM ingestion";
    homepage = "https://github.com/rtk-ai/rtk";
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
    mainProgram = "rtk";
  };
}
