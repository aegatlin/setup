asdf__prepare() {
  ensure_command git

  if ! has_command asdf; then
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf
    pushd ~/.asdf || exit
    git checkout "$(git describe --abbrev=0 --tags)"
    popd || exit
  fi

  # Until '. $HOME/.asdf/asdf.sh' is written to ~/.zshrc,
  # source asdf.sh to have access to the asdf command
  run_command "source $HOME/.asdf/asdf.sh"
}

asdf__setup() {
  ensure_command asdf

  plugin_add() {
    for tool in "$@"; do
      if ! asdf plugin list | grep -q "$tool"; then
        run_command "asdf plugin add $tool"
      fi
    done
  }

  plugin_add_and_global_install_latest() {
    plugin_add "$@"
    for tool in "$@"; do
      asdf install "$tool" "$(asdf latest "$tool")"
      asdf global "$tool" "$(asdf latest "$tool")"
      asdf reshim "$tool"
    done
  }

  plugin_add_and_global_install_latest \
    tmux \
    neovim \
    direnv \
    nodejs # required for nvim treesitter cli

  plugin_add \
    elixir \
    elm \
    erlang \
    kotlin \
    lua \
    postgres \
    python \
    shellspec \
    shellcheck \
    yarn
}

asdf__augment() {
  cat <<'DELIMIT' >>~/.zshrc
##########
# asdf setup
##########
# asdf itself
. $HOME/.asdf/asdf.sh
# for zsh completions, append asdf completion function locations to fpath
fpath=(${ASDF_DIR}/completions $fpath)
# direnv
eval "$(direnv hook zsh)"

DELIMIT
}

asdf__bootstrap() { :; }
