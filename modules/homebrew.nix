{ lib, userConfig, ... }:

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
      "oven-sh/bun"
    ];

    # All tap-only formulae migrated to nix (Phase 4) — none remaining
    brews = [];

    # Mac App Store apps (nix-darwin installs `mas` automatically)
    masApps = lib.optionalAttrs userConfig.installXcode {
      Xcode = 497799835;
    };

    # GUI applications — all managed via brew cask
    casks = [
      "amethyst"
      "font-iosevka"
      "ghostty"
      "jordanbaird-ice"
      "kitty"
      "maccy"
      "macdown"
      "ollama-app"
      "slack"
      "vscodium"
      "wave"
      "wezterm"
      "zed"
      "zen"
      "zoom"
    ];
  };
}
