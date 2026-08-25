{ pkgs, userConfig, ... }:

let
  fzfShare = "${pkgs.fzf}/share/fzf";
  inherit (userConfig) home;
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

      # ── SSH agent ──
      eval "ssh-add ~/.ssh/keys/good_key" &> /dev/null

      # ── Kitty SSH ──
      [ "$TERM" = "xterm-kitty" ] && alias ssh="kitty +kitten ssh"

      # ── Aliases (environment.shellAliases only works in bash, not zsh) ──
      alias gc='git branch --show-current'
      alias dicker='docker'
      alias assume='. assume'   # granted: must source to export AWS_* into current shell
      alias brew='env PATH="''${PATH//\/nix\/store\/[^\/]*\/bin:/}" brew'

      # ── Secrets (NOT in nix store) ──
      [ -f ~/.config/zsh/secrets.zsh ] && source ~/.config/zsh/secrets.zsh
    '';
  };

  # Direnv: auto-activate nix devShells on cd (includes nix-direnv for cached flake eval)
  programs.direnv.enable = true;

  # Starship prompt config — committed at modules/starship.toml, surfaced at /etc.
  environment.etc."starship.toml".source = ./starship.toml;

  environment.variables = {
    EDITOR = "vim";
    STARSHIP_CONFIG = "/etc/starship.toml";
  };

  environment.systemPath = [
    "${home}/.local/bin"
    "${home}/.bun/bin"
    # brew mysql-client is keg-only (no symlink into /opt/homebrew/bin)
    "/opt/homebrew/opt/mysql-client/bin"
  ];

  # Removed environment.shellAliases — they don't work in zsh, moved to interactiveShellInit above
}
