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

    # Third-party taps
    taps = [
      "birdayz/kaf"
      "common-fate/granted"
      "dicklesworthstone/tap"
      "huseyinbabal/tap"
      "jackielii/tap"
      "julien-cpsn/atac"
      "localstack/tap"
      "netbirdio/tap"
      "oven-sh/bun"
      "redpanda-data/tap"
      "steveyegge/beads"
    ];

    # Tap-only formulae (not available in nixpkgs, stay in brew)
    brews = [
      "birdayz/kaf/kaf"
      "jackielii/tap/skhd-zig"
      "huseyinbabal/tap/taws"
      "dicklesworthstone/tap/bv"
      "steveyegge/beads/bd"
      "julien-cpsn/atac/atac"
    ];

    # GUI applications — all managed via brew cask
    casks = [
      "amethyst"
      "bruno"
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
