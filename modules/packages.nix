{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Core CLI tools
    git
    git-crypt
    gnupg
    jq
    ripgrep
    fzf
    wget
    htop
    tmux
    zellij
    difftastic

    # Shell / prompt
    starship
    zoxide
    zsh-autosuggestions
    zinit

    # Cloud / infra
    awscli2
    opentofu          # terraform-compatible, no license issues
    snyk
    # localstack — broken in nixpkgs (plux test failure), keep in brew for now

    # Dev tools
    bun
    go_1_25            # global baseline; devShells add project-specific GOFLAGS/deps
    gradle
    phpPackages.composer
    # pyenv removed (Phase 5) — replaced by per-project devShells + direnv
    pipx
    opencode

    # Data / messaging
    apacheKafka
    influxdb2-cli
    mysql84
    redpanda-client   # rpk CLI
    kaf               # Kafka CLI

    # Containers
    docker-client     # CLI only, daemon via Docker Desktop cask

    # Networking / misc
    inetutils         # telnet, ftp, etc.
    speedtest-cli
    magic-wormhole
    terminal-notifier
    pay-respects      # thefuck replacement (thefuck removed from nixpkgs)
    atac              # API client TUI (postman-like)

    # Graphics / docs
    graphviz

    # System utilities
    logrotate
    usbutils          # lsusb
    portaudio
    bottom             # btm system monitor

    # Games
    nethack
    nsnake
    myman

    # Cloud auth
    granted

    # Tap-only packages (custom derivations in pkgs/)
    skhd-zig          # hotkey daemon (zig rewrite)
    taws              # terminal AWS TUI
    claude-history    # Claude Code conversation history TUI
    bd                # beads issue tracker
  ];
}
