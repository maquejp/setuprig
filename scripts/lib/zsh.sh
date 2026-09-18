#!/usr/bin/env bash

readonly ZSH_SHELL_PATH="/bin/zsh"

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