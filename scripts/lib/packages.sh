#!/usr/bin/env bash

readonly SUPPORTED_LINUX_DISTRIBUTIONS=(
  "ubuntu"
)

package_manager_apt_updated=0

readonly LINUX_COMPAT_BIN_DIR="$HOME/.local/bin"
readonly TLRC_GITHUB_REPOSITORY="tldr-pages/tlrc"

user_local_command_path() {
  local command_name="$1"
  local local_command_path="$HOME/.local/bin/$command_name"

  if command -v "$command_name" >/dev/null 2>&1; then
    command -v "$command_name"
    return 0
  fi

  if [[ -x "$local_command_path" ]]; then
    printf '%s
' "$local_command_path"
    return 0
  fi

  return 1
}

is_macos() {
  case "${OSTYPE:-}" in
    darwin*) return 0 ;;
    *) return 1 ;;
  esac
}

is_linux() {
  case "${OSTYPE:-}" in
    linux*) return 0 ;;
    *) return 1 ;;
  esac
}

linux_distribution_id() {
  if [[ -r /etc/os-release ]]; then
    awk -F= '/^ID=/{ gsub(/"/, "", $2); print $2 }' /etc/os-release
    return 0
  fi

  printf 'unknown\n'
}

linux_distribution_supported() {
  local distribution_id
  local supported_id

  distribution_id=$(linux_distribution_id)

  for supported_id in "${SUPPORTED_LINUX_DISTRIBUTIONS[@]}"; do
    if [[ "$distribution_id" == "$supported_id" ]]; then
      return 0
    fi
  done

  return 1
}

ensure_supported_os() {
  if is_linux && linux_distribution_supported; then
    return 0
  fi

  printf 'This branch currently supports Ubuntu Linux only.\n' >&2
  exit 1
}

run_with_sudo() {
  if ((EUID == 0)); then
    "$@"
    return 0
  fi

  if command -v sudo >/dev/null 2>&1; then
    sudo "$@"
    return 0
  fi

  printf 'This step requires elevated privileges, but sudo is not available.\n' >&2
  exit 1
}

apt_package_installed() {
  local package_name="$1"

  dpkg -s "$package_name" >/dev/null 2>&1
}

apt_package_available() {
  local package_name="$1"

  apt-cache show "$package_name" >/dev/null 2>&1
}

preferred_apt_package_name() {
  local tool_name="$1"

  case "$tool_name" in
    fd)
      printf 'fd-find\n'
      ;;
    openssl@3)
      printf 'openssl\n'
      ;;
    *)
      printf '%s\n' "$tool_name"
      ;;
  esac
}

ensure_linux_command_compatibility() {
  local tool_name="$1"
  local shim_name=""
  local shim_target=""

  case "$tool_name" in
    bat)
      shim_name="bat"
      if ! command -v bat >/dev/null 2>&1 && command -v batcat >/dev/null 2>&1; then
        shim_target=$(command -v batcat)
      fi
      ;;
    fd)
      shim_name="fd"
      if ! command -v fd >/dev/null 2>&1 && command -v fdfind >/dev/null 2>&1; then
        shim_target=$(command -v fdfind)
      fi
      ;;
    tlrc)
      shim_name="tlrc"
      if ! command -v tlrc >/dev/null 2>&1 && command -v tldr >/dev/null 2>&1; then
        shim_target=$(command -v tldr)
      fi
      ;;
  esac

  if [[ -z "$shim_name" || -z "$shim_target" ]]; then
    return 0
  fi

  mkdir -p "$LINUX_COMPAT_BIN_DIR"
  ln -sf "$shim_target" "$LINUX_COMPAT_BIN_DIR/$shim_name"
  printf 'Created Linux compatibility shim: %s -> %s\n' "$LINUX_COMPAT_BIN_DIR/$shim_name" "$shim_target"
}

package_installed() {
  local tool_name="$1"
  local package_name
  local resolved_command_path

  if [[ "$tool_name" == "mise" ]]; then
    user_local_command_path mise >/dev/null 2>&1
    return $?
  fi

  if [[ "$tool_name" == "pnpm" ]]; then
    if command -v pnpm >/dev/null 2>&1; then
      return 0
    fi

    if resolved_command_path=$(user_local_command_path mise 2>/dev/null); then
      local node_bin_dir
      node_bin_dir=$(dirname "$("$resolved_command_path" which node 2>/dev/null)")
      if [[ -n "$node_bin_dir" && -x "$node_bin_dir/pnpm" ]]; then
        return 0
      fi
    fi

    return 1
  fi

  if [[ "$tool_name" == "tlrc" ]]; then
    if command -v tlrc >/dev/null 2>&1 || command -v tldr >/dev/null 2>&1; then
      return 0
    fi

    return 1
  fi

  package_name=$(preferred_apt_package_name "$tool_name")
  apt_package_installed "$package_name"
}

package_available() {
  local tool_name="$1"
  local package_name

  package_name=$(preferred_apt_package_name "$tool_name")
  ensure_apt_updated
  apt_package_available "$package_name"
}

install_package() {
  local tool_name="$1"
  local package_name
  local resolved_command_path

  if [[ "$tool_name" == "mise" ]]; then
    if resolved_command_path=$(user_local_command_path mise 2>/dev/null); then
      printf 'mise is already available on the system at %s.\n' "$resolved_command_path"
      return 0
    fi

    if apt_package_available mise; then
      ensure_apt_package_installed mise
      return 0
    fi

    printf 'mise is missing; installing it with the official installer.\n'
    env PATH="$HOME/.local/bin:$PATH" sh -c 'curl -fsSL https://mise.run | sh'
    export PATH="$HOME/.local/bin:$PATH"
    return 0
  fi

  if [[ "$tool_name" == "pnpm" ]]; then
    if command -v pnpm >/dev/null 2>&1; then
      printf 'pnpm is already available on the system at %s.\n' "$(command -v pnpm)"
      return 0
    fi

    if apt_package_available pnpm; then
      ensure_apt_package_installed pnpm
      return 0
    fi

    if ! resolved_command_path=$(user_local_command_path mise 2>/dev/null); then
      printf 'pnpm requires mise-managed Node.js in this Ubuntu setup.\n' >&2
      exit 1
    fi

    printf 'pnpm is missing; installing it with npm through mise.\n'
    "$resolved_command_path" exec node@lts -- npm install -g pnpm

    local node_bin_dir
    node_bin_dir=$(dirname "$("$resolved_command_path" which node)")
    export PATH="$node_bin_dir:$PATH"
    return 0
  fi

  if [[ "$tool_name" == "tlrc" ]]; then
    if command -v tlrc >/dev/null 2>&1; then
      printf 'tlrc is already available on the system at %s.\n' "$(command -v tlrc)"
      return 0
    fi

    if command -v tldr >/dev/null 2>&1; then
      ensure_linux_command_compatibility tlrc
      printf 'tlrc is already available on the system at %s.\n' "$(command -v tldr)"
      return 0
    fi

    if apt_package_available tlrc; then
      ensure_apt_package_installed tlrc
      ensure_linux_command_compatibility tlrc
      return 0
    fi

    install_tlrc_release_package
    ensure_linux_command_compatibility tlrc
    return 0
  fi

  package_name=$(preferred_apt_package_name "$tool_name")
  ensure_apt_package_installed "$package_name"
  ensure_linux_command_compatibility "$tool_name"
}

print_package_status() {
  local tool_name="$1"
  local package_name
  local resolved_command_path

  if [[ "$tool_name" == "mise" ]]; then
    if resolved_command_path=$(user_local_command_path mise 2>/dev/null); then
      printf 'mise is installed at %s.\n' "$resolved_command_path"
      return 0
    fi

    printf 'mise could not be verified on PATH.\n' >&2
    return 1
  fi

  if [[ "$tool_name" == "pnpm" ]]; then
    if command -v pnpm >/dev/null 2>&1; then
      printf 'pnpm is installed at %s.\n' "$(command -v pnpm)"
      return 0
    fi

    if resolved_command_path=$(user_local_command_path mise 2>/dev/null); then
      local node_path node_bin_dir
      node_path=$("$resolved_command_path" which node 2>/dev/null || true)
      if [[ -n "$node_path" ]]; then
        node_bin_dir=$(dirname "$node_path")
        if [[ -x "$node_bin_dir/pnpm" ]]; then
          printf 'pnpm is installed at %s.\n' "$node_bin_dir/pnpm"
          return 0
        fi
      fi
    fi

    printf 'pnpm could not be verified on PATH.\n' >&2
    return 1
  fi

  if [[ "$tool_name" == "tlrc" ]]; then
    if command -v tlrc >/dev/null 2>&1; then
      printf 'tlrc is installed at %s.\n' "$(command -v tlrc)"
      return 0
    fi

    if command -v tldr >/dev/null 2>&1; then
      printf 'tlrc is installed at %s.\n' "$(command -v tldr)"
      return 0
    fi

    printf 'tlrc could not be verified on PATH.\n' >&2
    return 1
  fi

  package_name=$(preferred_apt_package_name "$tool_name")

  if apt_package_installed "$package_name"; then
    printf '%s is installed via apt (%s).\n' "$tool_name" "$package_name"
    return 0
  fi

  printf 'apt package could not be verified for %s (%s)\n' "$tool_name" "$package_name" >&2
  return 1
}

ensure_apt_updated() {
  if ((package_manager_apt_updated == 1)); then
    return 0
  fi

  run_with_sudo apt-get update
  package_manager_apt_updated=1
}

ensure_apt_package_installed() {
  local package_name="$1"

  if apt_package_installed "$package_name"; then
    printf '%s is already installed via apt.\n' "$package_name"
    return 0
  fi

  ensure_apt_updated
  printf '%s is missing; installing it with apt.\n' "$package_name"
  run_with_sudo apt-get install -y "$package_name"
}

print_apt_package_status() {
  local package_name="$1"

  if apt_package_installed "$package_name"; then
    printf '%s is installed via apt.\n' "$package_name"
    return 0
  fi

  printf 'apt package could not be verified: %s\n' "$package_name" >&2
  return 1
}

ensure_linux_build_prerequisites_installed() {
  ensure_apt_package_installed build-essential
  ensure_apt_package_installed procps
  ensure_apt_package_installed curl
  ensure_apt_package_installed file
  ensure_apt_package_installed git
}

ensure_package_installed() {
  local tool_name="$1"

  if [[ "$tool_name" == "mise" ]]; then
    install_package "$tool_name"
    return 0
  fi

  if [[ "$tool_name" == "pnpm" || "$tool_name" == "tlrc" ]]; then
    install_package "$tool_name"
    return 0
  fi

  if package_available "$tool_name"; then
    install_package "$tool_name"
    return 0
  fi

  printf 'Required package is not available via apt on Ubuntu: %s\n' "$tool_name" >&2
  exit 1
}

ensure_packages_installed() {
  local tool_name

  for tool_name in "$@"; do
    ensure_package_installed "$tool_name"
  done
}

print_packages_status() {
  local tool_name

  for tool_name in "$@"; do
    print_package_status "$tool_name" || return 1
  done
}

tlrc_release_architecture() {
  local machine_architecture

  machine_architecture=$(dpkg --print-architecture)

  case "$machine_architecture" in
    amd64)
      printf 'x86_64'
      ;;
    arm64)
      printf 'aarch64'
      ;;
    *)
      printf 'Unsupported architecture for tlrc release packages: %s\n' "$machine_architecture" >&2
      return 1
      ;;
  esac
}

tlrc_release_asset_url() {
  local architecture
  local asset_suffix

  architecture=$(tlrc_release_architecture) || return 1
  asset_suffix="${architecture}-unknown-linux-gnu.deb"

  curl -fsSL "https://api.github.com/repos/${TLRC_GITHUB_REPOSITORY}/releases/latest" \
    | tr ',' '\n' \
    | grep -oE '"browser_download_url":[[:space:]]*"[^"]*' \
    | cut -d'"' -f4 \
    | grep "${asset_suffix}$" \
    | head -n 1
}

install_tlrc_release_package() {
  local asset_url
  local temp_package_file

  asset_url=$(tlrc_release_asset_url || true)
  if [[ -z "$asset_url" ]]; then
    printf 'Could not determine a tlrc release package for this architecture.\n' >&2
    exit 1
  fi

  temp_package_file=$(mktemp --suffix=.deb)
  curl -fsSL "$asset_url" -o "$temp_package_file"
  ensure_apt_updated
  run_with_sudo apt-get install -y "$temp_package_file"
  rm -f "$temp_package_file"
}