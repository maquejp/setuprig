#!/usr/bin/env bash

xcode_cli_installed() {
  xcode-select -p >/dev/null 2>&1
}

ensure_xcode_cli_installed() {
  local install_output

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
  if xcode_cli_installed; then
    printf 'Xcode Command Line Tools are installed.\n'
    return 0
  fi

  printf 'Xcode Command Line Tools could not be verified.\n' >&2
  return 1
}