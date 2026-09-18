#!/usr/bin/env bash

brew_bin_path() {
  if command -v brew >/dev/null 2>&1; then
    command -v brew
    return 0
  fi

  if [[ -x /opt/homebrew/bin/brew ]]; then
    printf '/opt/homebrew/bin/brew\n'
    return 0
  fi

  if [[ -x /usr/local/bin/brew ]]; then
    printf '/usr/local/bin/brew\n'
    return 0
  fi

  return 1
}

ensure_macos() {
  case "${OSTYPE:-}" in
    darwin*) ;;
    *)
      printf 'This script only targets macOS.\n' >&2
      exit 1
      ;;
  esac
}

setup_homebrew_environment() {
  local brew_bin
  brew_bin=$(brew_bin_path) || {
    printf 'Homebrew is not available.\n' >&2
    exit 1
  }

  eval "$($brew_bin shellenv)"
}

ensure_homebrew_installed() {
  if brew_bin_path >/dev/null 2>&1; then
    printf 'Homebrew is already installed.\n'
    return 0
  fi

  printf 'Homebrew is missing; installing it.\n'
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

print_homebrew_version() {
  local brew_bin
  brew_bin=$(brew_bin_path) || {
    printf 'Homebrew installation completed, but brew is not available yet.\n' >&2
    exit 1
  }

  "$brew_bin" --version | head -n 1
}
