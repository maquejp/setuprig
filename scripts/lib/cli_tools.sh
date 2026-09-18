#!/usr/bin/env bash

readonly DEFAULT_CLI_TOOLS=(
  "jq"
  "yq"
  "tmux"
)

ensure_default_cli_tools_installed() {
  ensure_homebrew_formulae_installed "${DEFAULT_CLI_TOOLS[@]}"
}

print_default_cli_tools_status() {
  print_homebrew_formulae_status "${DEFAULT_CLI_TOOLS[@]}"
  printf 'Default CLI tools are installed via Homebrew.\n'
}

ensure_fzf_installed() {
  ensure_homebrew_formula_installed "fzf"
}

print_fzf_status() {
  print_homebrew_formula_status "fzf"
}

ensure_fd_installed() {
  ensure_homebrew_formula_installed "fd"
}

print_fd_status() {
  print_homebrew_formula_status "fd"
}

ensure_direnv_installed() {
  ensure_homebrew_formula_installed "direnv"
}

print_direnv_status() {
  print_homebrew_formula_status "direnv"
}

ensure_tlrc_installed() {
  ensure_homebrew_formula_installed "tlrc"
}

print_tlrc_status() {
  print_homebrew_formula_status "tlrc"
}

ensure_pnpm_installed() {
  ensure_homebrew_formula_installed "pnpm"
}

print_pnpm_status() {
  print_homebrew_formula_status "pnpm"
}