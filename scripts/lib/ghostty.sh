#!/usr/bin/env bash

ghostty_lib_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
ghostty_repo_root=$(cd -- "$ghostty_lib_dir/../.." && pwd)

readonly GHOSTTY_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/com.mitchellh.ghostty"
readonly GHOSTTY_CONFIG_FILE="$GHOSTTY_CONFIG_DIR/config.ghostty"
readonly GHOSTTY_BASE_SETTINGS_FILE="$ghostty_repo_root/config/ghostty/base.ghostty"
readonly GHOSTTY_APT_PACKAGE_NAME="ghostty"
readonly GHOSTTY_UBUNTU_COMMUNITY_PACKAGE_URL="https://github.com/mkasberg/ghostty-ubuntu"

install_ghostty_cask() {
  ensure_apt_updated

  if apt_package_available "$GHOSTTY_APT_PACKAGE_NAME"; then
    ensure_apt_package_installed "$GHOSTTY_APT_PACKAGE_NAME"
    return 0
  fi

  printf 'Ghostty is not available from the configured Ubuntu repositories. On Ubuntu 26.04+ you can use the official package with apt, and on older Ubuntu releases you can use the community package from %s. Install Ghostty manually, then rerun this step.\n' "$GHOSTTY_UBUNTU_COMMUNITY_PACKAGE_URL" >&2
  exit 1
}

ghostty_available() {
  command -v ghostty >/dev/null 2>&1
}

ensure_ghostty_installed() {
  if ghostty_available; then
    printf 'Ghostty is already available on the system.\n'
    return 0
  fi

  if apt_package_installed "$GHOSTTY_APT_PACKAGE_NAME"; then
    printf 'Ghostty is already installed via apt.\n'
    return 0
  fi

  printf 'Ghostty is missing; installing it with apt when available.\n'
  install_ghostty_cask
}

print_ghostty_status() {
  if ghostty_available; then
    printf 'Ghostty is available on the system.\n'
    return 0
  fi

  if apt_package_installed "$GHOSTTY_APT_PACKAGE_NAME"; then
    printf 'Ghostty is installed via apt.\n'
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
