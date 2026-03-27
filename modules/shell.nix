{ pkgs, ... }:

{
  # Phase 3 will migrate shell config here.
  # For now, just enable zsh so nix-darwin doesn't fight the existing setup.
  programs.zsh.enable = true;
}
