#!/usr/bin/env bash

readonly DEFAULT_CLI_TOOLS=(
  "jq"
  "yq"
  "tmux"
)

ensure_default_cli_tools_installed() {
  ensure_packages_installed "${DEFAULT_CLI_TOOLS[@]}"
}

print_default_cli_tools_status() {
  print_packages_status "${DEFAULT_CLI_TOOLS[@]}"
  printf 'Default CLI tools are installed.\n'
}

ensure_fzf_installed() {
  ensure_package_installed "fzf"
}

print_fzf_status() {
  print_package_status "fzf"
}

ensure_fd_installed() {
  ensure_package_installed "fd"
}

print_fd_status() {
  print_package_status "fd"
}

ensure_direnv_installed() {
  ensure_package_installed "direnv"
}

print_direnv_status() {
  print_package_status "direnv"
}

ensure_tlrc_installed() {
  ensure_package_installed "tlrc"
}

print_tlrc_status() {
  print_package_status "tlrc"
}

ensure_pnpm_installed() {
  ensure_package_installed "pnpm"
}

print_pnpm_status() {
  print_package_status "pnpm"
}