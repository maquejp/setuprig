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

homebrew_formula_installed() {
  local formula_name="$1"

  brew list --formula "$formula_name" >/dev/null 2>&1
}

ensure_homebrew_formula_installed() {
  local formula_name="$1"

  if homebrew_formula_installed "$formula_name"; then
    printf '%s is already installed via Homebrew.\n' "$formula_name"
    return 0
  fi

  printf '%s is missing; installing it with Homebrew.\n' "$formula_name"
  brew install "$formula_name"
}

ensure_homebrew_formulae_installed() {
  local formula_name

  for formula_name in "$@"; do
    ensure_homebrew_formula_installed "$formula_name"
  done
}

print_homebrew_formula_status() {
  local formula_name="$1"

  if homebrew_formula_installed "$formula_name"; then
    printf '%s is installed via Homebrew.\n' "$formula_name"
    return 0
  fi

  printf 'Homebrew formula could not be verified: %s\n' "$formula_name" >&2
  return 1
}

print_homebrew_formulae_status() {
  local formula_name

  for formula_name in "$@"; do
    print_homebrew_formula_status "$formula_name" || return 1
  done
}

print_homebrew_version() {
  local brew_bin
  brew_bin=$(brew_bin_path) || {
    printf 'Homebrew installation completed, but brew is not available yet.\n' >&2
    exit 1
  }

  "$brew_bin" --version | head -n 1
}
