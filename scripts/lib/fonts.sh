#!/usr/bin/env bash

readonly JETBRAINS_MONO_CASK_NAME="font-jetbrains-mono-nerd-font"
readonly JETBRAINS_MONO_REQUIRED_FILES=(
  "JetBrainsMonoNerdFontMono-Regular.ttf"
  "JetBrainsMonoNerdFontMono-Bold.ttf"
  "JetBrainsMonoNerdFontMono-Italic.ttf"
  "JetBrainsMonoNerdFontMono-BoldItalic.ttf"
)

jetbrains_mono_font_present() {
  local font_dir
  local required_file
  local required_file_found

  for font_dir in "$HOME/Library/Fonts" "/Library/Fonts"; do
    [[ -d "$font_dir" ]] || continue

    required_file_found=1

    for required_file in "${JETBRAINS_MONO_REQUIRED_FILES[@]}"; do
      if [[ ! -f "$font_dir/$required_file" ]]; then
        required_file_found=0
        break
      fi
    done

    if [[ $required_file_found -eq 1 ]]; then
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
    printf 'JetBrains Mono Nerd Font is already installed via Homebrew.\n'
    return 0
  fi

  if jetbrains_mono_font_present; then
    printf 'JetBrains Mono Nerd Font files already exist. Skipping Homebrew installation.\n'
    return 0
  fi

  printf 'JetBrains Mono Nerd Font is missing; installing it with Homebrew.\n'
  install_jetbrains_mono
}

print_jetbrains_mono_status() {
  if brew list --cask "$JETBRAINS_MONO_CASK_NAME" >/dev/null 2>&1; then
    printf 'JetBrains Mono Nerd Font is installed via Homebrew.\n'
    return 0
  fi

  if jetbrains_mono_font_present; then
    printf 'JetBrains Mono Nerd Font files are installed.\n'
    return 0
  fi

  printf 'JetBrains Mono Nerd Font installation could not be verified.\n' >&2
  return 1
}