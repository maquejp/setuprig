#!/usr/bin/env bash

readonly JETBRAINS_MONO_APT_PACKAGE_NAME="fonts-jetbrains-mono"
readonly JETBRAINS_MONO_REQUIRED_FILES=(
  "JetBrainsMono-Regular.ttf"
  "JetBrainsMono-Bold.ttf"
  "JetBrainsMono-Italic.ttf"
  "JetBrainsMono-BoldItalic.ttf"
)

jetbrains_mono_font_present() {
  local font_dir
  local required_file
  local required_file_found

  while IFS= read -r font_dir; do
    [[ -d "$font_dir" ]] || continue

    required_file_found=1

    for required_file in "${JETBRAINS_MONO_REQUIRED_FILES[@]}"; do
      if ! find "$font_dir" -type f -name "$required_file" -print -quit | grep -q .; then
        required_file_found=0
        break
      fi
    done

    if [[ $required_file_found -eq 1 ]]; then
      return 0
    fi
  done < <(jetbrains_mono_font_directories)

  return 1
}

jetbrains_mono_font_directories() {
  printf '%s\n' "$HOME/.local/share/fonts" "/usr/local/share/fonts" "/usr/share/fonts"
}

install_jetbrains_mono() {
  ensure_apt_updated

  if apt_package_available "$JETBRAINS_MONO_APT_PACKAGE_NAME"; then
    ensure_apt_package_installed "$JETBRAINS_MONO_APT_PACKAGE_NAME"
    return 0
  fi

  printf 'JetBrains Mono automatic installation is not available from the configured Ubuntu repositories. Install it manually, then rerun this step.\n' >&2
  exit 1
}

ensure_jetbrains_mono_installed() {
  if jetbrains_mono_font_present; then
    printf 'JetBrains Mono core font files already exist. Skipping package installation.\n'
    return 0
  fi

  printf 'JetBrains Mono is missing; installing it with apt when available.\n'
  install_jetbrains_mono
}

print_jetbrains_mono_status() {
  if apt_package_installed "$JETBRAINS_MONO_APT_PACKAGE_NAME"; then
    printf 'JetBrains Mono is installed via apt.\n'
    return 0
  fi

  if jetbrains_mono_font_present; then
    printf 'JetBrains Mono core font files are installed.\n'
    return 0
  fi

  printf 'JetBrains Mono installation could not be verified.\n' >&2
  return 1
}