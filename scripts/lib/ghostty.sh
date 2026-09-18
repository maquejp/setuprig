#!/usr/bin/env bash

ghostty_lib_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
ghostty_repo_root=$(cd -- "$ghostty_lib_dir/../.." && pwd)

readonly GHOSTTY_CONFIG_DIR="$HOME/Library/Application Support/com.mitchellh.ghostty"
readonly GHOSTTY_CONFIG_FILE="$GHOSTTY_CONFIG_DIR/config.ghostty"
readonly GHOSTTY_BASE_SETTINGS_FILE="$ghostty_repo_root/config/ghostty/base.ghostty"
readonly GHOSTTY_APP_PATH="/Applications/Ghostty.app"

install_ghostty_cask() {
  brew install --cask ghostty
}

ensure_ghostty_installed() {
  if brew list --cask ghostty >/dev/null 2>&1; then
    printf 'Ghostty is already installed via Homebrew.\n'
    return 0
  fi

  if [[ -d "$GHOSTTY_APP_PATH" ]]; then
    printf 'Ghostty already exists at %s. Skipping Homebrew installation.\n' "$GHOSTTY_APP_PATH"
    return 0
  fi

  printf 'Ghostty is missing; installing it with Homebrew.\n'
  install_ghostty_cask
}

print_ghostty_status() {
  if brew list --cask ghostty >/dev/null 2>&1; then
    printf 'Ghostty is installed via Homebrew.\n'
    return 0
  fi

  if [[ -d "$GHOSTTY_APP_PATH" ]]; then
    printf 'Ghostty is installed at %s.\n' "$GHOSTTY_APP_PATH"
    return 0
  fi

  printf 'Ghostty installation could not be verified.\n' >&2
  return 1
}

apply_ghostty_base_settings() {
  if [[ ! -f "$GHOSTTY_BASE_SETTINGS_FILE" ]]; then
    printf 'Ghostty base settings file is missing: %s\n' "$GHOSTTY_BASE_SETTINGS_FILE" >&2
    exit 1
  fi

  mkdir -p "$GHOSTTY_CONFIG_DIR"
  cp "$GHOSTTY_BASE_SETTINGS_FILE" "$GHOSTTY_CONFIG_FILE"

  printf 'Ghostty config overwritten from %s to %s\n' "$GHOSTTY_BASE_SETTINGS_FILE" "$GHOSTTY_CONFIG_FILE"
}
