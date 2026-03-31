{ ... }:

{
  # Let nix-darwin manage Homebrew declaratively.
  # It calls `brew install`/`brew uninstall` to converge state.
  homebrew = {
    enable = true;

    # On `darwin-rebuild switch`:
    # - Install anything declared here but missing from brew
    # - Do NOT uninstall things not declared here (yet) — we're migrating gradually
    onActivation = {
      autoUpdate = false;   # don't run `brew update` on every rebuild
      cleanup = "none";     # "none" = don't uninstall undeclared packages
                            # change to "uninstall" once migration is complete
    };

    # Third-party taps (only those still serving brew formulae or casks)
    taps = [
      "common-fate/granted"
      "localstack/tap"
      "netbirdio/tap"
      "oven-sh/bun"
      "redpanda-data/tap"
    ];

    # All tap-only formulae migrated to nix (Phase 4) — none remaining
    brews = [];

    # GUI applications — all managed via brew cask
    casks = [
      "amethyst"
      "bruno"
      "cmux"
      "docker-desktop"
      "font-iosevka"
      "ghostty"
      "goland"
      "jetbrains-toolbox"
      "jordanbaird-ice"
      "kitty"
      "maccy"
      "macdown"
      "netbird-ui"
      "ollama-app"
      "postman"
      "proxyman"
      "slack"
      "studio-3t"
      "tableplus"
      "vscodium"
      "wave"
      "wezterm"
      "zed"
      "zen"
      "zoom"
    ];
  };
}
