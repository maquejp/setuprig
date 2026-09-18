#!/usr/bin/env bash

set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

# shellcheck source=./scripts/lib/homebrew.sh
source "$script_dir/scripts/lib/homebrew.sh"

# shellcheck source=./scripts/lib/fonts.sh
source "$script_dir/scripts/lib/fonts.sh"

# shellcheck source=./scripts/lib/ghostty.sh
source "$script_dir/scripts/lib/ghostty.sh"

usage() {
  cat <<'EOF'
Usage: bash setup.sh <step>

Available steps:
  homebrew   Ensure Homebrew is installed
  jetbrains-mono Ensure JetBrains Mono is installed
  ghostty    Ensure Homebrew is installed, then install Ghostty
  all        Run all currently implemented steps
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

run_all_steps() {
  run_homebrew_step
  run_jetbrains_mono_step
  run_ghostty_step
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
