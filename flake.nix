{
  description = "Eamon's nix-darwin system configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-darwin }: {
    darwinConfigurations."Eamons-MacBook-Pro" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        ./hosts/eamon.nix
      ];
    };
  };
}
