#!/usr/bin/env bash

set -euo pipefail

install_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    printf 'Homebrew is already installed: %s\n' "$(command -v brew)"
    return 0
  fi

  printf 'Homebrew is missing; installing it.\n'
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

verify_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    brew --version | head -n 1
    return 0
  fi

  local brew_bin
  if [[ -x /opt/homebrew/bin/brew ]]; then
    brew_bin=/opt/homebrew/bin/brew
  elif [[ -x /usr/local/bin/brew ]]; then
    brew_bin=/usr/local/bin/brew
  else
    printf 'Homebrew installation completed, but brew is not on PATH yet.\n' >&2
    return 1
  fi

  "$brew_bin" --version | head -n 1
}

main() {
  case "${OSTYPE:-}" in
    darwin*) ;;
    *)
      printf 'This script only targets macOS.\n' >&2
      exit 1
      ;;
  esac

  install_homebrew
  verify_homebrew
}

main