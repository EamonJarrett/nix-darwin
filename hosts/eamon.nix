{ pkgs, ... }:

{
  imports = [
    ../modules/packages.nix
    ../modules/homebrew.nix
    ../modules/shell.nix
    ../modules/caveman.nix
  ];

  # System identity
  networking.hostName = "Eamons-MacBook-Pro";

  # Platform
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Allow unfree packages (terraform, etc.)
  nixpkgs.config.allowUnfree = true;

  # Nix daemon settings
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    # Lix-specific: preserve existing substituters from /etc/nix/nix.conf
    extra-trusted-substituters = [ "https://cache.lix.systems" ];
    extra-trusted-public-keys = [ "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o=" ];
  };

  # Auto-upgrade nix-darwin itself
  system.stateVersion = 6;

  # Required for homebrew and other user-scoped nix-darwin options
  system.primaryUser = "eamon";

  # User account
  users.users.eamon = {
    name = "eamon";
    home = "/Users/eamon";
  };
}
