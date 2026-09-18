#!/usr/bin/env bash

starship_lib_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
starship_repo_root=$(cd -- "$starship_lib_dir/../.." && pwd)

readonly STARSHIP_FORMULA_NAME="starship"
readonly STARSHIP_CONFIG_DIR="$HOME/.config"
readonly STARSHIP_CONFIG_FILE="$STARSHIP_CONFIG_DIR/starship.toml"
readonly STARSHIP_BASE_CONFIG_FILE="$starship_repo_root/config/starship.toml"

ensure_starship_installed() {
  ensure_homebrew_formula_installed "$STARSHIP_FORMULA_NAME"
}

print_starship_status() {
  print_homebrew_formula_status "$STARSHIP_FORMULA_NAME"
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