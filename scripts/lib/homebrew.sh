#!/usr/bin/env bash

readonly SUPPORTED_LINUX_DISTRIBUTIONS=(
  "ubuntu"
  "debian"
)

package_manager_apt_updated=0

is_macos() {
  case "${OSTYPE:-}" in
    darwin*) return 0 ;;
    *) return 1 ;;
  esac
}

is_linux() {
  case "${OSTYPE:-}" in
    linux*) return 0 ;;
    *) return 1 ;;
  esac
}

linux_distribution_id() {
  if [[ -r /etc/os-release ]]; then
    awk -F= '/^ID=/{ gsub(/"/, "", $2); print $2 }' /etc/os-release
    return 0
  fi

  printf 'unknown\n'
}

linux_distribution_supported() {
  local distribution_id
  local supported_id

  distribution_id=$(linux_distribution_id)

  for supported_id in "${SUPPORTED_LINUX_DISTRIBUTIONS[@]}"; do
    if [[ "$distribution_id" == "$supported_id" ]]; then
      return 0
    fi
  done

  return 1
}

ensure_supported_os() {
  if is_macos; then
    return 0
  fi

  if is_linux && linux_distribution_supported; then
    return 0
  fi

  if is_linux; then
    printf 'This script currently supports macOS and Ubuntu/Debian Linux.\n' >&2
    exit 1
  fi

  printf 'This script currently supports macOS and Ubuntu/Debian Linux.\n' >&2
  exit 1
}

run_with_sudo() {
  if ((EUID == 0)); then
    "$@"
    return 0
  fi

  if command -v sudo >/dev/null 2>&1; then
    sudo "$@"
    return 0
  fi

  printf 'This step requires elevated privileges, but sudo is not available.\n' >&2
  exit 1
}

apt_package_installed() {
  local package_name="$1"

  dpkg -s "$package_name" >/dev/null 2>&1
}

apt_package_available() {
  local package_name="$1"

  apt-cache show "$package_name" >/dev/null 2>&1
}

ensure_apt_updated() {
  if ((package_manager_apt_updated == 1)); then
    return 0
  fi

  run_with_sudo apt-get update
  package_manager_apt_updated=1
}

ensure_apt_package_installed() {
  local package_name="$1"

  if apt_package_installed "$package_name"; then
    printf '%s is already installed via apt.\n' "$package_name"
    return 0
  fi

  ensure_apt_updated
  printf '%s is missing; installing it with apt.\n' "$package_name"
  run_with_sudo apt-get install -y "$package_name"
}

print_apt_package_status() {
  local package_name="$1"

  if apt_package_installed "$package_name"; then
    printf '%s is installed via apt.\n' "$package_name"
    return 0
  fi

  printf 'apt package could not be verified: %s\n' "$package_name" >&2
  return 1
}

ensure_linux_homebrew_prerequisites_installed() {
  if ! is_linux; then
    return 0
  fi

  ensure_apt_package_installed build-essential
  ensure_apt_package_installed procps
  ensure_apt_package_installed curl
  ensure_apt_package_installed file
  ensure_apt_package_installed git
}

brew_bin_path() {
  if command -v brew >/dev/null 2>&1; then
    command -v brew
    return 0
  fi

  if [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    printf '/home/linuxbrew/.linuxbrew/bin/brew\n'
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

  if is_linux; then
    ensure_linux_homebrew_prerequisites_installed
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
