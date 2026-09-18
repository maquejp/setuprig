#!/usr/bin/env bash

git_lib_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
git_repo_root=$(cd -- "$git_lib_dir/../.." && pwd)

readonly GIT_REQUIRED_PACKAGES=(
  "gh"
  "git-delta"
)
readonly GIT_CONFIG_DIR="$HOME/.config/git"
readonly GIT_CONFIG_FILE="$GIT_CONFIG_DIR/config"
readonly GIT_BASE_CONFIG_FILE="$git_repo_root/config/git/config"
readonly GIT_HOME_CONFIG_FILE="$HOME/.gitconfig"
readonly GIT_MANAGED_INCLUDE_PATH="~/.config/git/config"

git_available() {
  command -v git >/dev/null 2>&1
}

ensure_git_installed() {
  if package_installed "git"; then
    printf 'Git is already installed via apt.\n'
    return 0
  fi

  if git_available; then
    printf 'Git is already available on the system at %s. Skipping package installation.\n' "$(command -v git)"
    return 0
  fi

  printf 'Git is missing; installing it with apt.\n'
  ensure_package_installed "git"
}

ensure_git_tooling_installed() {
  ensure_git_installed
  ensure_packages_installed "${GIT_REQUIRED_PACKAGES[@]}"
}

print_git_status() {
  if package_installed "git"; then
    printf 'Git is installed via apt.\n'
    return 0
  fi

  if git_available; then
    printf 'Git is available on the system at %s.\n' "$(command -v git)"
    return 0
  fi

  printf 'Git could not be verified.\n' >&2
  return 1
}

print_git_tooling_status() {
  print_git_status || return 1
  print_packages_status "${GIT_REQUIRED_PACKAGES[@]}"
  printf 'Git tooling is ready.\n'
}

ensure_git_base_config_present() {
  if [[ -f "$GIT_BASE_CONFIG_FILE" ]]; then
    return 0
  fi

  printf 'Git base config file is missing: %s\n' "$GIT_BASE_CONFIG_FILE" >&2
  exit 1
}

git_home_config_includes_managed_config() {
  [[ -f "$GIT_HOME_CONFIG_FILE" ]] && grep -Fq "$GIT_MANAGED_INCLUDE_PATH" "$GIT_HOME_CONFIG_FILE"
}

ensure_git_home_include() {
  if git_home_config_includes_managed_config; then
    return 0
  fi

  if [[ ! -f "$GIT_HOME_CONFIG_FILE" ]]; then
    cat > "$GIT_HOME_CONFIG_FILE" <<EOF
[include]
	path = $GIT_MANAGED_INCLUDE_PATH
EOF
    return 0
  fi

  printf '\n[include]\n\tpath = %s\n' "$GIT_MANAGED_INCLUDE_PATH" >> "$GIT_HOME_CONFIG_FILE"
}

apply_git_configuration() {
  ensure_git_base_config_present

  mkdir -p "$GIT_CONFIG_DIR"
  cp "$GIT_BASE_CONFIG_FILE" "$GIT_CONFIG_FILE"
  ensure_git_home_include

  printf 'Git config synchronized to %s\n' "$GIT_CONFIG_FILE"
  printf 'Git include ensured in %s\n' "$GIT_HOME_CONFIG_FILE"
}

print_git_configuration_status() {
  if [[ ! -f "$GIT_CONFIG_FILE" ]]; then
    printf 'Managed Git config could not be verified: %s\n' "$GIT_CONFIG_FILE" >&2
    return 1
  fi

  if ! git_home_config_includes_managed_config; then
    printf 'Managed Git include could not be verified in %s\n' "$GIT_HOME_CONFIG_FILE" >&2
    return 1
  fi

  printf 'Managed Git config is active from %s\n' "$GIT_CONFIG_FILE"
}