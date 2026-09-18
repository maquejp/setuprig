#!/usr/bin/env bash

xcode_cli_installed() {
  if is_linux; then
    apt_package_installed build-essential
    return $?
  fi

  xcode-select -p >/dev/null 2>&1
}

ensure_xcode_cli_installed() {
  local install_output

  if is_linux; then
    ensure_linux_build_prerequisites_installed
    printf 'Linux build prerequisites are installed.\n'
    return 0
  fi

  if xcode_cli_installed; then
    printf 'Xcode Command Line Tools are already installed.\n'
    return 0
  fi

  printf 'Xcode Command Line Tools are missing; requesting installation.\n'

  install_output=$(xcode-select --install 2>&1 || true)

  if [[ -n "$install_output" ]]; then
    printf '%s\n' "$install_output"
  fi

  printf 'Complete the Xcode Command Line Tools installation, then rerun this step.\n' >&2
  exit 1
}

print_xcode_cli_status() {
  if is_linux; then
    print_apt_package_status build-essential || return 1
    printf 'Linux build prerequisites are installed.\n'
    return 0
  fi

  if xcode_cli_installed; then
    printf 'Xcode Command Line Tools are installed.\n'
    return 0
  fi

  printf 'Xcode Command Line Tools could not be verified.\n' >&2
  return 1
}