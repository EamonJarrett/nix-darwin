{ lib, stdenvNoCC, fetchurl }:

let
  version = "0.0.17";
  assets = {
    aarch64-darwin = {
      url = "https://github.com/jackielii/skhd.zig/releases/download/v${version}/skhd-arm64-macos.tar.gz";
      hash = "sha256-1lvvQoUOCxpus07L5KsG1l30GI+LP+KkvLGQN12KFhs=";
      bin = "skhd-arm64-macos";
    };
    x86_64-darwin = {
      url = "https://github.com/jackielii/skhd.zig/releases/download/v${version}/skhd-x86_64-macos.tar.gz";
      hash = "sha256-TUBa0GUy1ObJ+yFcS4TT+y0cPYYdCdxdBYvj7R2q7Pw=";
      bin = "skhd-x86_64-macos";
    };
  };
  asset = assets.${stdenvNoCC.hostPlatform.system}
    or (throw "skhd-zig: unsupported system ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation {
  pname = "skhd-zig";
  inherit version;

  src = fetchurl {
    inherit (asset) url hash;
  };

  sourceRoot = ".";

  installPhase = ''
    install -Dm755 ${asset.bin} $out/bin/skhd
  '';

  meta = {
    description = "Simple hotkey daemon for macOS, written in Zig";
    homepage = "https://github.com/jackielii/skhd.zig";
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
    mainProgram = "skhd";
  };
}
