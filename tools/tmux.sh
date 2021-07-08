tmux__prepare() { :; }

tmux__setup() {
  after asdf__setup

  if is_mac; then
    after brew__setup
    brew install automake
  fi

  if is_ubuntu; then
    after apt__setup
    sudo apt install --assume--yes libevent-dev ncurses-dev build-essential \
      bison pkg-config zip unzip automake
  fi

  asdf plugin add tmux
  asdf install tmux latest
  asdf global tmux "$(asdf latest tmux)"
}

tmux__augment() {
  ensure_dir "$HOME/.config"
  ensure_dir "$HOME/.config/tmux"
  curl -fsSL "${CONFIG_URL}"/tmux/tmux.conf > "$HOME/.config/tmux/tmux.conf"
}

tmux__bootstrap() { :; }