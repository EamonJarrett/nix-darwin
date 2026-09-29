{ lib, stdenvNoCC, fetchurl }:

let
  version = "0.2.0";
  # 0.2.0 ships a .app bundle; the daemon binary lives inside it.
  bin = "skhd.app/Contents/MacOS/skhd";
  assets = {
    aarch64-darwin = {
      url = "https://github.com/jackielii/skhd.zig/releases/download/v${version}/skhd-arm64-macos.tar.gz";
      hash = "sha256-C0jY80n2tzhJ4zj+jfpdwUB39Yuu6Y4B4qp4TWchs0A=";
    };
    x86_64-darwin = {
      url = "https://github.com/jackielii/skhd.zig/releases/download/v${version}/skhd-x86_64-macos.tar.gz";
      hash = "sha256-I1ROsPIz9jckCzlJ/9SSKSkZUuoV6gD0jr0q8f/ASH8=";
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
    install -Dm755 ${bin} $out/bin/skhd
  '';

  meta = {
    description = "Simple hotkey daemon for macOS, written in Zig";
    homepage = "https://github.com/jackielii/skhd.zig";
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
    mainProgram = "skhd";
  };
}
