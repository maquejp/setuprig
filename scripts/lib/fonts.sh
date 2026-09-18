#!/usr/bin/env bash

readonly JETBRAINS_MONO_CASK_NAME="font-jetbrains-mono"

jetbrains_mono_font_present() {
  local font_dir

  for font_dir in "$HOME/Library/Fonts" "/Library/Fonts"; do
    [[ -d "$font_dir" ]] || continue

    if find "$font_dir" -maxdepth 1 \( -iname 'JetBrainsMono*.ttf' -o -iname 'JetBrainsMono*.otf' -o -iname 'JetBrainsMono*.ttc' \) | grep -q .; then
      return 0
    fi
  done

  return 1
}

install_jetbrains_mono() {
  brew install --cask "$JETBRAINS_MONO_CASK_NAME"
}

ensure_jetbrains_mono_installed() {
  if brew list --cask "$JETBRAINS_MONO_CASK_NAME" >/dev/null 2>&1; then
    printf 'JetBrains Mono is already installed via Homebrew.\n'
    return 0
  fi

  if jetbrains_mono_font_present; then
    printf 'JetBrains Mono font files already exist. Skipping Homebrew installation.\n'
    return 0
  fi

  printf 'JetBrains Mono is missing; installing it with Homebrew.\n'
  install_jetbrains_mono
}

print_jetbrains_mono_status() {
  if brew list --cask "$JETBRAINS_MONO_CASK_NAME" >/dev/null 2>&1; then
    printf 'JetBrains Mono is installed via Homebrew.\n'
    return 0
  fi

  if jetbrains_mono_font_present; then
    printf 'JetBrains Mono font files are installed.\n'
    return 0
  fi

  printf 'JetBrains Mono installation could not be verified.\n' >&2
  return 1
}