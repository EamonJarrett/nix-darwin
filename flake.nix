{
  description = "Eamon's nix-darwin system configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-darwin }:
  let
    system = "aarch64-darwin";
    # Overlay: custom derivations for packages not in nixpkgs
    customPackages = final: prev: {
      skhd-zig = final.callPackage ./pkgs/skhd-zig.nix { };
      taws     = final.callPackage ./pkgs/taws.nix { };
      claude-history = final.callPackage ./pkgs/claude-history.nix { };
      bd       = final.callPackage ./pkgs/bd.nix { };

      # nixpkgs-unstable direnv 2.37.1: CGO_ENABLED=0 but Makefile uses -linkmode=external
      direnv = prev.direnv.overrideAttrs (old: { env = (old.env or {}) // { CGO_ENABLED = "1"; }; });
    };
  in
  {
    darwinConfigurations."Eamons-MacBook-Pro" = nix-darwin.lib.darwinSystem {
      inherit system;
      modules = [
        { nixpkgs.overlays = [ customPackages ]; }
        ./hosts/eamon.nix
      ];
    };
  };
}
