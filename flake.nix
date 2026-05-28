{
  description = "Eamon's nix-darwin system configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # Separate, fast-moving pin for bun (upstream nags hard on stale versions).
    # Update with: nix flake update nixpkgs-bun
    nixpkgs-bun.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    caveman-src = {
      url = "github:JuliusBrussee/caveman";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, nixpkgs-bun, nix-darwin, caveman-src }:
  let
    system = "aarch64-darwin";
    bunPkgs = import nixpkgs-bun { inherit system; config.allowUnfree = true; };
    # Overlay: custom derivations for packages not in nixpkgs
    customPackages = final: prev: {
      skhd-zig = final.callPackage ./pkgs/skhd-zig.nix { };
      claude-history = final.callPackage ./pkgs/claude-history.nix { };
      bd       = final.callPackage ./pkgs/bd.nix { };
      gascity  = final.callPackage ./pkgs/gascity.nix { };
      dolt     = final.callPackage ./pkgs/dolt.nix { };
      graphify = final.callPackage ./pkgs/graphify.nix { };
      rtk      = final.callPackage ./pkgs/rtk.nix { };

      # Bun on its own fast-moving pin + manual version bump ahead of nixpkgs.
      # nixpkgs tip currently ships 1.3.13; bump to 1.3.14 (needed by oh-my-posh /
      # other tooling that nags on stale bun and can't write into /nix/store).
      # When nixpkgs-bun catches up, drop the overrideAttrs and `nix flake update nixpkgs-bun`.
      bun = bunPkgs.bun.overrideAttrs (prev: rec {
        version = "1.3.14";
        passthru = prev.passthru // {
          sources = prev.passthru.sources // {
            "aarch64-darwin" = final.fetchurl {
              url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-darwin-aarch64.zip";
              hash = "sha256-2LliIYKK1vl6x6wKt+lYcjQa92MAHogD6CZ2UsJlJiA=";
            };
          };
        };
        src = passthru.sources.${final.stdenvNoCC.hostPlatform.system};
      });

      # nixpkgs-unstable direnv 2.37.1: CGO_ENABLED=0 but Makefile uses -linkmode=external
      direnv = prev.direnv.overrideAttrs (old: { env = (old.env or {}) // { CGO_ENABLED = "1"; }; });
    };

    mkHost = hostFile: nix-darwin.lib.darwinSystem {
      inherit system;
      specialArgs = { inherit caveman-src; };
      modules = [
        { nixpkgs.overlays = [ customPackages ]; }
        hostFile
      ];
    };
  in
  {
    darwinConfigurations = {
      eamon              = mkHost ./hosts/eamon.nix;
      eamonjarrett-mann  = mkHost ./hosts/eamonjarrett-mann.nix;

      # Both machines share the hostname "Eamons-MacBook-Pro", so
      # `darwin-rebuild switch --flake .` (which looks up the hostname)
      # is ambiguous. The original machine keeps the hostname alias for
      # the eamon user; the other machine must invoke explicitly with
      # `darwin-rebuild switch --flake .#eamonjarrett-mann`.
      "Eamons-MacBook-Pro" = self.darwinConfigurations.eamon;
    };
  };
}
