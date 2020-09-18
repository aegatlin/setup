#!/bin/zsh

load_tools () {
  __message "Setup initiated"
  __message "Loading remote tools..."
  for arg in "$@"; do
    echo $arg
    _load_remote_tool "$arg"
  done
}

_load_remote_tool () {
  temp="$(mktemp ./temp.sh.XXX)"
  chmod 744 "$temp"
  curl -fsSL "https://raw.githubusercontent.com/aegatlin/setup/master/tools/$1" > "$temp"
  source "$temp"
}

clean_up () {
  __message "Cleaning up"
  rm -f ./temp.sh.*
  rm -f ./bootstrap.sh
  __message "Setup complete"
  echo
}

__message () {
  echo
  echo "**********"
  echo "$1"
  echo "**********"
}

__has_command () {
  command -v $1 1> /dev/null
}

__run_command () {
  echo
  if [[ $# -eq 2 ]]; then
    echo "Executing command: $1 ($2)"
  else
    echo "Executing command: $1"
  fi

  eval $1
}

__ensure_command () {
  if ! __has_command "$1"; then
    __message "ERROR..."
    echo "$1 not installed..."
    echo "Exiting..."
    clean_up
    exit
  fi
}