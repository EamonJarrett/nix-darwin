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

      # Bun on its own fast-moving pin; nixpkgs-bun tip currently ships 1.4.2
      # (latest upstream). If upstream runs ahead again, re-add an overrideAttrs
      # here with a manual version + hash.
      bun = bunPkgs.bun;

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
