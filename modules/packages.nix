{ pkgs, lib, userConfig, ... }:

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

    # Dev tools
    bun
    nodejs_20         # node + npm; Tauri/vite/playwright pipeline (mobile CI pinned to Node 20)
    go_1_25            # global baseline; devShells add project-specific GOFLAGS/deps
    pipx
    opencode
    rustup            # iOS targets added at runtime: rustup target add aarch64-apple-ios{,-sim} x86_64-apple-ios
    cocoapods
    maestro           # mobile UI automation CLI (maestro.mobile.dev) — Layer 4 iOS regression flows

    # Containers
    docker-client     # CLI; daemon runs in colima VM
    colima            # docker daemon in a lightweight Linux VM
    docker-compose
    docker-buildx

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

    # Tap-only packages (custom derivations in pkgs/)
    skhd-zig          # hotkey daemon (zig rewrite)
    claude-history    # Claude Code conversation history TUI
    bd                # beads issue tracker
    gascity           # gc CLI (Gas City supervisor); needs dolt + flock at runtime
    dolt              # required by gascity (>= 1.86.2)
    flock             # file locking; required by gascity
    graphify          # graphifyy: codebase → knowledge graph (Python/JS/Rust/C#/SQL only; other langs need tree-sitter-* grammars added to nixpkgs)
    rtk               # Rust Token Killer: shell command output compressor (Claude Code hook via `rtk init -g`)
  ] ++ lib.optionals userConfig.installXcode [
    xcodegen          # regenerates src-tauri/gen/apple/project.yml for Tauri iOS builds; requires Xcode
  ];
}
