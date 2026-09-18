#!/usr/bin/env bash

readonly SUPPORTED_LINUX_DISTRIBUTIONS=(
  "ubuntu"
)

package_manager_apt_updated=0

readonly LINUX_COMPAT_BIN_DIR="$HOME/.local/bin"

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
  if is_linux && linux_distribution_supported; then
    return 0
  fi

  printf 'This branch currently supports Ubuntu Linux only.\n' >&2
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

preferred_apt_package_name() {
  local tool_name="$1"

  case "$tool_name" in
    fd)
      printf 'fd-find\n'
      ;;
    openssl@3)
      printf 'openssl\n'
      ;;
    *)
      printf '%s\n' "$tool_name"
      ;;
  esac
}

ensure_linux_command_compatibility() {
  local tool_name="$1"
  local shim_name=""
  local shim_target=""

  case "$tool_name" in
    bat)
      shim_name="bat"
      if ! command -v bat >/dev/null 2>&1 && command -v batcat >/dev/null 2>&1; then
        shim_target=$(command -v batcat)
      fi
      ;;
    fd)
      shim_name="fd"
      if ! command -v fd >/dev/null 2>&1 && command -v fdfind >/dev/null 2>&1; then
        shim_target=$(command -v fdfind)
      fi
      ;;
  esac

  if [[ -z "$shim_name" || -z "$shim_target" ]]; then
    return 0
  fi

  mkdir -p "$LINUX_COMPAT_BIN_DIR"
  ln -sf "$shim_target" "$LINUX_COMPAT_BIN_DIR/$shim_name"
  printf 'Created Linux compatibility shim: %s -> %s\n' "$LINUX_COMPAT_BIN_DIR/$shim_name" "$shim_target"
}

package_installed() {
  local tool_name="$1"
  local package_name

  if [[ "$tool_name" == "mise" ]]; then
    command -v mise >/dev/null 2>&1
    return $?
  fi

  package_name=$(preferred_apt_package_name "$tool_name")
  apt_package_installed "$package_name"
}

package_available() {
  local tool_name="$1"
  local package_name

  package_name=$(preferred_apt_package_name "$tool_name")
  ensure_apt_updated
  apt_package_available "$package_name"
}

install_package() {
  local tool_name="$1"
  local package_name

  if [[ "$tool_name" == "mise" ]]; then
    if command -v mise >/dev/null 2>&1; then
      printf 'mise is already available on the system at %s.\n' "$(command -v mise)"
      return 0
    fi

    if apt_package_available mise; then
      ensure_apt_package_installed mise
      return 0
    fi

    printf 'mise is missing; installing it with the official installer.\n'
    env PATH="$HOME/.local/bin:$PATH" sh -c 'curl -fsSL https://mise.run | sh'
    export PATH="$HOME/.local/bin:$PATH"
    return 0
  fi

  package_name=$(preferred_apt_package_name "$tool_name")
  ensure_apt_package_installed "$package_name"
  ensure_linux_command_compatibility "$tool_name"
}

print_package_status() {
  local tool_name="$1"
  local package_name

  if [[ "$tool_name" == "mise" ]]; then
    if command -v mise >/dev/null 2>&1; then
      printf 'mise is installed at %s.\n' "$(command -v mise)"
      return 0
    fi

    printf 'mise could not be verified on PATH.\n' >&2
    return 1
  fi

  package_name=$(preferred_apt_package_name "$tool_name")

  if apt_package_installed "$package_name"; then
    printf '%s is installed via apt (%s).\n' "$tool_name" "$package_name"
    return 0
  fi

  printf 'apt package could not be verified for %s (%s)\n' "$tool_name" "$package_name" >&2
  return 1
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

ensure_linux_build_prerequisites_installed() {
  ensure_apt_package_installed build-essential
  ensure_apt_package_installed procps
  ensure_apt_package_installed curl
  ensure_apt_package_installed file
  ensure_apt_package_installed git
}

ensure_package_installed() {
  local tool_name="$1"

  if [[ "$tool_name" == "mise" ]]; then
    install_package "$tool_name"
    return 0
  fi

  if package_available "$tool_name"; then
    install_package "$tool_name"
    return 0
  fi

  printf 'Required package is not available via apt on Ubuntu: %s\n' "$tool_name" >&2
  exit 1
}

ensure_packages_installed() {
  local tool_name

  for tool_name in "$@"; do
    ensure_package_installed "$tool_name"
  done
}

print_packages_status() {
  local tool_name

  for tool_name in "$@"; do
    print_package_status "$tool_name" || return 1
  done
}