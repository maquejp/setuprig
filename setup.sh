#!/usr/bin/env bash

set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

# shellcheck source=./scripts/lib/homebrew.sh
source "$script_dir/scripts/lib/homebrew.sh"

# shellcheck source=./scripts/lib/fonts.sh
source "$script_dir/scripts/lib/fonts.sh"

# shellcheck source=./scripts/lib/ghostty.sh
source "$script_dir/scripts/lib/ghostty.sh"

# shellcheck source=./scripts/lib/xcode.sh
source "$script_dir/scripts/lib/xcode.sh"

# shellcheck source=./scripts/lib/git.sh
source "$script_dir/scripts/lib/git.sh"

# shellcheck source=./scripts/lib/cli_tools.sh
source "$script_dir/scripts/lib/cli_tools.sh"

# shellcheck source=./scripts/lib/starship.sh
source "$script_dir/scripts/lib/starship.sh"

# shellcheck source=./scripts/lib/zsh.sh
source "$script_dir/scripts/lib/zsh.sh"

# shellcheck source=./scripts/lib/runtimes.sh
source "$script_dir/scripts/lib/runtimes.sh"

usage() {
  cat <<'EOF'
Usage: bash setup.sh <step>

Available steps:
  homebrew   Ensure Homebrew is installed
  jetbrains-mono Ensure JetBrains Mono is installed
  ghostty    Ensure Homebrew is installed, then install Ghostty
  xcode-cli  Ensure Xcode Command Line Tools are installed
  git        Ensure Git, GitHub CLI, and delta are installed and configured
  cli-tools  Ensure jq, yq, and tmux are installed
  runtimes   Ensure mise installs Node LTS and Python 3
  zsh        Ensure zsh is present and the default login shell
  fzf        Install fzf on explicit request
  fd         Install fd on explicit request
  direnv     Install direnv on explicit request
  tlrc       Install tlrc on explicit request
  pnpm       Install pnpm on explicit request
  all        Run all default setup steps
EOF
}

run_homebrew_step() {
  ensure_homebrew_installed
  print_homebrew_version
}

run_jetbrains_mono_step() {
  ensure_homebrew_installed
  setup_homebrew_environment
  ensure_jetbrains_mono_installed
  print_jetbrains_mono_status
}

run_ghostty_step() {
  ensure_homebrew_installed
  setup_homebrew_environment
  ensure_ghostty_installed
  apply_ghostty_base_settings
  print_ghostty_status
}

run_xcode_cli_step() {
  ensure_xcode_cli_installed
  print_xcode_cli_status
}

run_git_step() {
  ensure_homebrew_installed
  setup_homebrew_environment
  ensure_xcode_cli_installed
  ensure_git_tooling_installed
  apply_git_configuration
  print_git_tooling_status
  print_git_configuration_status
}

run_cli_tools_step() {
  ensure_homebrew_installed
  setup_homebrew_environment
  ensure_xcode_cli_installed
  ensure_default_cli_tools_installed
  print_default_cli_tools_status
}

run_runtimes_step() {
  ensure_homebrew_installed
  setup_homebrew_environment
  ensure_xcode_cli_installed
  ensure_mise_installed
  apply_mise_configuration
  install_managed_runtimes
  print_runtimes_status
}

run_zsh_step() {
  ensure_homebrew_installed
  setup_homebrew_environment
  ensure_starship_installed
  ensure_zsh_runtime_dependencies_installed
  ensure_zsh_present
  ensure_zsh_allowed_shell
  ensure_zsh_default_shell
  apply_starship_configuration
  apply_zsh_base_configuration
  print_starship_status
  print_zsh_runtime_dependency_status
  print_zsh_status
}

run_fzf_step() {
  ensure_homebrew_installed
  setup_homebrew_environment
  ensure_xcode_cli_installed
  ensure_fzf_installed
  print_fzf_status
}

run_fd_step() {
  ensure_homebrew_installed
  setup_homebrew_environment
  ensure_xcode_cli_installed
  ensure_fd_installed
  print_fd_status
}

run_direnv_step() {
  ensure_homebrew_installed
  setup_homebrew_environment
  ensure_xcode_cli_installed
  ensure_direnv_installed
  print_direnv_status
}

run_tlrc_step() {
  ensure_homebrew_installed
  setup_homebrew_environment
  ensure_xcode_cli_installed
  ensure_tlrc_installed
  print_tlrc_status
}

run_pnpm_step() {
  ensure_homebrew_installed
  setup_homebrew_environment
  ensure_xcode_cli_installed
  ensure_pnpm_installed
  print_pnpm_status
}

run_all_steps() {
  run_homebrew_step
  run_jetbrains_mono_step
  run_ghostty_step
  run_xcode_cli_step
  run_git_step
  run_cli_tools_step
  run_runtimes_step
  run_zsh_step
}

main() {
  ensure_macos

  if (($# != 1)); then
    usage >&2
    exit 1
  fi

  case "$1" in
    homebrew)
      run_homebrew_step
      ;;
    jetbrains-mono)
      run_jetbrains_mono_step
      ;;
    ghostty)
      run_ghostty_step
      ;;
    xcode-cli)
      run_xcode_cli_step
      ;;
    git)
      run_git_step
      ;;
    cli-tools)
      run_cli_tools_step
      ;;
    runtimes)
      run_runtimes_step
      ;;
    zsh)
      run_zsh_step
      ;;
    fzf)
      run_fzf_step
      ;;
    fd)
      run_fd_step
      ;;
    direnv)
      run_direnv_step
      ;;
    tlrc)
      run_tlrc_step
      ;;
    pnpm)
      run_pnpm_step
      ;;
    all)
      run_all_steps
      ;;
    -h|--help|help)
      usage
      ;;
    *)
      printf 'Unknown step: %s\n' "$1" >&2
      usage >&2
      exit 1
      ;;
  esac
}

main "$@"
