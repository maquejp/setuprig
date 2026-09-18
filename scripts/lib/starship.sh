#!/usr/bin/env bash

starship_lib_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
starship_repo_root=$(cd -- "$starship_lib_dir/../.." && pwd)

readonly STARSHIP_FORMULA_NAME="starship"
readonly STARSHIP_CONFIG_DIR="$HOME/.config"
readonly STARSHIP_CONFIG_FILE="$STARSHIP_CONFIG_DIR/starship.toml"
readonly STARSHIP_BASE_CONFIG_FILE="$starship_repo_root/config/starship.toml"

ensure_starship_installed() {
  if brew list --formula "$STARSHIP_FORMULA_NAME" >/dev/null 2>&1; then
    printf 'Starship is already installed via Homebrew.\n'
    return 0
  fi

  printf 'Starship is missing; installing it with Homebrew.\n'
  brew install "$STARSHIP_FORMULA_NAME"
}

print_starship_status() {
  if brew list --formula "$STARSHIP_FORMULA_NAME" >/dev/null 2>&1; then
    printf 'Starship is installed via Homebrew.\n'
    return 0
  fi

  printf 'Starship installation could not be verified.\n' >&2
  return 1
}

ensure_starship_base_config_present() {
  if [[ -f "$STARSHIP_BASE_CONFIG_FILE" ]]; then
    return 0
  fi

  printf 'Starship base config file is missing: %s\n' "$STARSHIP_BASE_CONFIG_FILE" >&2
  exit 1
}

apply_starship_configuration() {
  ensure_starship_base_config_present

  mkdir -p "$STARSHIP_CONFIG_DIR"
  cp "$STARSHIP_BASE_CONFIG_FILE" "$STARSHIP_CONFIG_FILE"

  printf 'Starship config synchronized to %s\n' "$STARSHIP_CONFIG_FILE"
}