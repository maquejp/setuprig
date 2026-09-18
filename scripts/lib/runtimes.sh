#!/usr/bin/env bash

runtimes_lib_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
runtimes_repo_root=$(cd -- "$runtimes_lib_dir/../.." && pwd)

readonly MISE_FORMULA_NAME="mise"
readonly MISE_CONFIG_DIR="$HOME/.config/mise"
readonly MISE_CONFIG_FILE="$MISE_CONFIG_DIR/config.toml"
readonly MISE_BASE_CONFIG_FILE="$runtimes_repo_root/config/mise/config.toml"
readonly MISE_REQUIRED_TOOLS=(
  "node"
  "python"
)

ensure_mise_installed() {
  ensure_homebrew_formula_installed "$MISE_FORMULA_NAME"
}

print_mise_status() {
  print_homebrew_formula_status "$MISE_FORMULA_NAME"
}

ensure_mise_base_config_present() {
  if [[ -f "$MISE_BASE_CONFIG_FILE" ]]; then
    return 0
  fi

  printf 'mise base config file is missing: %s\n' "$MISE_BASE_CONFIG_FILE" >&2
  exit 1
}

apply_mise_configuration() {
  ensure_mise_base_config_present

  mkdir -p "$MISE_CONFIG_DIR"
  cp "$MISE_BASE_CONFIG_FILE" "$MISE_CONFIG_FILE"

  printf 'mise config synchronized to %s\n' "$MISE_CONFIG_FILE"
}

install_managed_runtimes() {
  mise install
}

mise_tool_installed() {
  local tool_name="$1"

  mise ls --global --installed "$tool_name" 2>/dev/null | awk 'NR > 1 && NF { found = 1 } END { exit found ? 0 : 1 }'
}

print_runtimes_status() {
  local tool_name

  print_mise_status || return 1

  for tool_name in "${MISE_REQUIRED_TOOLS[@]}"; do
    if ! mise_tool_installed "$tool_name"; then
      printf 'Managed runtime could not be verified with mise: %s\n' "$tool_name" >&2
      return 1
    fi
  done

  printf 'Managed runtimes are installed with mise.\n'
}