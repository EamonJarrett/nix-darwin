{ pkgs, ... }:

let
  fzfShare = "${pkgs.fzf}/share/fzf";
in
{
  programs.zsh = {
    enable = true;

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

      # ── Pyenv ──
      export PYENV_ROOT="$HOME/.pyenv"
      [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
      eval "$(pyenv init -)"

      # ── Goenv ──
      export GOENV_ROOT="$HOME/.goenv"
      export PATH="$GOENV_ROOT/bin:$PATH"
      eval "$(goenv init -)"
      export PATH="$GOROOT/bin:$PATH"
      export PATH="$PATH:$GOPATH/bin"

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
      alias mds='mls-data-sync'
      alias mdc='mls-data-cli'
      alias dicker='docker'
      alias sail='[ -f sail ] && sh sail || sh vendor/bin/sail'
      alias assume='. assume'
      alias brew='env PATH="''${PATH//$(pyenv root)\/shims:/}" brew'

      # ── PATH additions (spaces in paths break environment.systemPath) ──
      export PATH="$PATH:/Users/eamon/Library/Application Support/JetBrains/Toolbox/scripts"

      # ── Secrets (NOT in nix store) ──
      [ -f ~/.config/zsh/secrets.zsh ] && source ~/.config/zsh/secrets.zsh
    '';
  };

  environment.variables = {
    EDITOR = "vim";
    CGO_CFLAGS = "-Wno-gnu-folding-constant";
  };

  environment.systemPath = [
    "/Users/eamon/.local/bin"
    "/Users/eamon/.bun/bin"
  ];

  # Removed environment.shellAliases — they don't work in zsh, moved to interactiveShellInit above
}
