{ pkgs, ... }:

{
  # Phase 2 will populate this with CLI tools migrated from Homebrew.
  # For now, just the essentials to verify nix-darwin works.
  environment.systemPackages = with pkgs; [
    # Placeholder — add packages here as they're migrated from brew
  ];
}
