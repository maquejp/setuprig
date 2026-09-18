#!/usr/bin/env bash

zsh_lib_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
zsh_repo_root=$(cd -- "$zsh_lib_dir/../.." && pwd)

readonly ZSH_SHELL_PATH="/bin/zsh"
readonly ZSH_REQUIRED_FORMULAE=(
  "mise"
  "zoxide"
  "eza"
  "bat"
  "ripgrep"
  "openssl@3"
)
readonly ZSH_HOME_SHIM_FILE="$HOME/.zshenv"
readonly ZSH_CONFIG_DIR="$HOME/.config/zsh"
readonly ZSH_STATE_DIR="$HOME/.local/state/zsh"
readonly ZSH_HISTORY_FILE="$ZSH_STATE_DIR/history"
readonly ZSH_BASE_CONFIG_DIR="$zsh_repo_root/config/zsh"
readonly ZSH_MANAGED_FILES=(
  ".zshenv"
  ".zshrc"
  "aliases.zsh"
  "prompt.zsh"
)

ensure_zsh_present() {
  if [[ -x "$ZSH_SHELL_PATH" ]]; then
    return 0
  fi

  printf 'zsh is missing at %s.\n' "$ZSH_SHELL_PATH" >&2
  exit 1
}

ensure_zsh_allowed_shell() {
  if grep -Fxq "$ZSH_SHELL_PATH" /etc/shells; then
    return 0
  fi

  printf 'zsh is not listed in /etc/shells: %s\n' "$ZSH_SHELL_PATH" >&2
  exit 1
}

ensure_zsh_runtime_dependencies_installed() {
  local formula_name

  for formula_name in "${ZSH_REQUIRED_FORMULAE[@]}"; do
    if brew list --formula "$formula_name" >/dev/null 2>&1; then
      printf '%s is already installed via Homebrew.\n' "$formula_name"
      continue
    fi

    printf '%s is missing; installing it with Homebrew.\n' "$formula_name"
    brew install "$formula_name"
  done
}

print_zsh_runtime_dependency_status() {
  local formula_name

  for formula_name in "${ZSH_REQUIRED_FORMULAE[@]}"; do
    if ! brew list --formula "$formula_name" >/dev/null 2>&1; then
      printf 'Required zsh dependency could not be verified: %s\n' "$formula_name" >&2
      return 1
    fi
  done

  printf 'zsh runtime dependencies are installed via Homebrew.\n'
}

ensure_zsh_base_config_present() {
  local managed_file

  for managed_file in "${ZSH_MANAGED_FILES[@]}"; do
    if [[ ! -f "$ZSH_BASE_CONFIG_DIR/$managed_file" ]]; then
      printf 'zsh base config file is missing: %s/%s\n' "$ZSH_BASE_CONFIG_DIR" "$managed_file" >&2
      exit 1
    fi
  done
}

sync_zsh_config() {
  local managed_file

  mkdir -p "$ZSH_CONFIG_DIR"

  for managed_file in "${ZSH_MANAGED_FILES[@]}"; do
    cp "$ZSH_BASE_CONFIG_DIR/$managed_file" "$ZSH_CONFIG_DIR/$managed_file"
  done
}

write_home_zshenv_shim() {
  cat > "$ZSH_HOME_SHIM_FILE" <<'EOF'
export ZDOTDIR="$HOME/.config/zsh"

if [[ -f "$ZDOTDIR/.zshenv" ]]; then
  source "$ZDOTDIR/.zshenv"
fi
EOF
}

ensure_zsh_history_path() {
  mkdir -p "$ZSH_STATE_DIR"
  touch "$ZSH_HISTORY_FILE"
  chmod 600 "$ZSH_HISTORY_FILE"
}

current_user_shell() {
  dscl . -read /Users/"$(whoami)" UserShell 2>/dev/null | awk '/UserShell:/ { print $2 }'
}

ensure_zsh_default_shell() {
  local configured_shell

  configured_shell=$(current_user_shell)

  if [[ "$configured_shell" == "$ZSH_SHELL_PATH" ]]; then
    printf 'zsh is already the default login shell.\n'
    return 0
  fi

  printf 'Changing default login shell from %s to %s.\n' "$configured_shell" "$ZSH_SHELL_PATH"
  chsh -s "$ZSH_SHELL_PATH"
}

print_zsh_status() {
  local configured_shell

  configured_shell=$(current_user_shell)

  if [[ "$configured_shell" == "$ZSH_SHELL_PATH" ]]; then
    printf 'Default login shell is %s.\n' "$configured_shell"
    return 0
  fi

  printf 'Default login shell could not be verified as zsh. Current value: %s\n' "$configured_shell" >&2
  return 1
}

apply_zsh_base_configuration() {
  ensure_zsh_base_config_present
  sync_zsh_config
  write_home_zshenv_shim
  ensure_zsh_history_path

  printf 'zsh config synchronized to %s\n' "$ZSH_CONFIG_DIR"
  printf 'zsh history ensured at %s\n' "$ZSH_HISTORY_FILE"
}