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
    # localstack — broken in nixpkgs (plux test failure), keep in brew for now

    # Dev tools
    bun
    gradle
    phpPackages.composer
    pyenv             # Phase 5: replace with devShells
    pipx
    opencode

    # Data / messaging
    apacheKafka
    influxdb2-cli
    mysql84
    redpanda-client   # rpk CLI

    # Containers
    docker-client     # CLI only, daemon via Docker Desktop cask

    # Networking / misc
    inetutils         # telnet, ftp, etc.
    speedtest-cli
    magic-wormhole
    terminal-notifier
    pay-respects      # thefuck replacement (thefuck removed from nixpkgs)

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
  ];
}
