{ pkgs, ... }:

let
  fzfShare = "${pkgs.fzf}/share/fzf";
in
{
  programs.zsh = {
    enable = true;
    promptInit = ""; # disable default 'suse' prompt that overwrites starship

    interactiveShellInit = ''
      # ── Zinit plugin manager ──
      ZINIT_HOME="${pkgs.zinit}/share/zinit"
      source "''${ZINIT_HOME}/zinit.zsh"
      zinit light redxtech/zsh-kitty

      # ── Zsh autosuggestions ──
      source ${pkgs.zsh-autosuggestions}/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

      # ── Fzf shell integration ──
      source ${fzfShare}/completion.zsh
      source ${fzfShare}/key-bindings.zsh

      # ── Tool init ──
      eval "$(pay-respects zsh)"
      eval "$(starship init zsh)"
      eval "$(zoxide init zsh)"

      # ── Kaf completions ──
      if command -v kaf &>/dev/null; then
        kaf completion zsh > "''${fpath[1]}/_kaf" 2>/dev/null
      fi

      # ── SSH agent ──
      eval "ssh-add ~/.ssh/keys/good_key" &> /dev/null

      # ── Kitty SSH ──
      [ "$TERM" = "xterm-kitty" ] && alias ssh="kitty +kitten ssh"

      # ── Aliases (environment.shellAliases only works in bash, not zsh) ──
      alias gc='git branch --show-current'
      alias dt='dev-tool'
      alias dicker='docker'
      alias sail='[ -f sail ] && sh sail || sh vendor/bin/sail'
      alias assume='. assume'
      alias brew='env PATH="''${PATH//\/nix\/store\/[^\/]*\/bin:/}" brew'

      # ── PATH additions (spaces in paths break environment.systemPath) ──
      export PATH="$PATH:/Users/eamon/Library/Application Support/JetBrains/Toolbox/scripts"

      # ── Secrets (NOT in nix store) ──
      [ -f ~/.config/zsh/secrets.zsh ] && source ~/.config/zsh/secrets.zsh
    '';
  };

  # Direnv: auto-activate nix devShells on cd (includes nix-direnv for cached flake eval)
  programs.direnv.enable = true;

  environment.variables = {
    EDITOR = "vim";
    # -I/-L for libjpeg_turbo: vendor/github.com/pixiv/go-libjpeg hardcodes
    # /opt/homebrew/opt/jpeg-turbo paths that don't exist on this nix-managed
    # system; cgo merges these env flags in, letting clang/ld find the
    # nix-store copy instead. Non-existent -I/-L dirs are ignored by the toolchain.
    CGO_CFLAGS  = "-Wno-gnu-folding-constant -I${pkgs.libjpeg_turbo.dev}/include";
    CGO_LDFLAGS = "-L${pkgs.libjpeg_turbo.out}/lib";
  };

  environment.systemPath = [
    "/Users/eamon/.local/bin"
    "/Users/eamon/.bun/bin"
  ];

  # Removed environment.shellAliases — they don't work in zsh, moved to interactiveShellInit above
}
