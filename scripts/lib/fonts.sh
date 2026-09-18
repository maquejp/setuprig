#!/usr/bin/env bash

readonly JETBRAINS_MONO_NERD_FONT_NAME="JetBrainsMono Nerd Font"
readonly JETBRAINS_MONO_NERD_FONT_RELEASE_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz"
readonly JETBRAINS_MONO_FONT_DIR="$HOME/.local/share/fonts"
JETBRAINS_MONO_TEMP_DIR=""

jetbrains_mono_font_present() {
  fc-match -f '%{family}\n' "$JETBRAINS_MONO_NERD_FONT_NAME" 2>/dev/null | grep -Fxq "$JETBRAINS_MONO_NERD_FONT_NAME"
}

install_jetbrains_mono() {
  if jetbrains_mono_font_present; then
    return 0
  fi

  JETBRAINS_MONO_TEMP_DIR=$(mktemp -d)
  trap 'rm -rf "$JETBRAINS_MONO_TEMP_DIR"' RETURN

  mkdir -p "$JETBRAINS_MONO_FONT_DIR"
  curl -fsSL "$JETBRAINS_MONO_NERD_FONT_RELEASE_URL" -o "$JETBRAINS_MONO_TEMP_DIR/JetBrainsMono.tar.xz"
  tar -xf "$JETBRAINS_MONO_TEMP_DIR/JetBrainsMono.tar.xz" -C "$JETBRAINS_MONO_TEMP_DIR"
  find "$JETBRAINS_MONO_TEMP_DIR" -type f \( -name '*.ttf' -o -name '*.otf' \) -exec cp -f {} "$JETBRAINS_MONO_FONT_DIR"/ \;

  if command -v fc-cache >/dev/null 2>&1; then
    fc-cache -f "$JETBRAINS_MONO_FONT_DIR" >/dev/null 2>&1 || true
  fi
}

ensure_jetbrains_mono_installed() {
  if jetbrains_mono_font_present; then
    printf 'JetBrains Mono Nerd Font is already installed.\n'
    return 0
  fi

  printf 'JetBrains Mono Nerd Font is missing; installing the Nerd Font release.\n'
  install_jetbrains_mono
}

print_jetbrains_mono_status() {
  if jetbrains_mono_font_present; then
    printf 'JetBrains Mono Nerd Font is installed.\n'
    return 0
  fi

  printf 'JetBrains Mono Nerd Font installation could not be verified.\n' >&2
  return 1
}