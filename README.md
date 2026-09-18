# setuprig

This branch is the Ubuntu setup variant of the repo.

Current steps:

1. Ensure Ubuntu build prerequisites are installed.
2. Ensure JetBrains Mono is installed when the Ubuntu package is available.
3. Ensure Ghostty is installed from Ubuntu repositories when available and apply the base Ghostty settings.
4. Ensure Git tooling is installed and the managed Git config is active.
5. Ensure the default CLI tools are installed.
6. Ensure the managed runtime baseline is installed with mise.
7. Ensure zsh is present and the default login shell.

Optional steps can install extra tools only when you request them.

Current scope covers Ubuntu terminal bootstrap, developer CLI tooling,
Git/GitHub tooling, and a minimal runtime baseline. Optional tools stay out of
the default path until you request them.

Usage:

```bash
bash setup.sh jetbrains-mono
bash setup.sh ghostty
bash setup.sh build-tools
bash setup.sh git
bash setup.sh cli-tools
bash setup.sh runtimes
bash setup.sh zsh
bash setup.sh fzf
bash setup.sh fd
bash setup.sh direnv
bash setup.sh tlrc
bash setup.sh pnpm
bash setup.sh all
```

Notes:

- `setup.sh build-tools` installs the Ubuntu build prerequisites required by
  the rest of the developer tooling.
- `setup.sh jetbrains-mono` installs JetBrains Mono from Ubuntu repositories
  when the `fonts-jetbrains-mono` package is available and otherwise asks you
  to install the font manually.
- `setup.sh ghostty` installs and configures Ghostty. The config is written to
  the XDG Ghostty config path. On Ubuntu it tries the `ghostty` apt package
  when the repositories provide it. If the package is not available, install
  Ghostty manually and rerun the step.
- `setup.sh git` ensures the build prerequisites are present, installs `gh`
  and `git-delta` with `apt`, treats an existing system `git` as sufficient,
  synchronizes the managed Git config to `~/.config/git/config`, and ensures
  `~/.gitconfig` includes that managed config without overwriting existing user
  settings.
- `setup.sh cli-tools` ensures the build prerequisites are present, then
  installs the default CLI tools: `jq`, `yq`, and `tmux` with `apt`.
- `setup.sh runtimes` ensures the build prerequisites are present, ensures
  `mise` is installed using `apt` when available, synchronizes
  synchronizes
  `~/.config/mise/config.toml`, and installs the managed runtime baseline:
  Node LTS and Python 3. `npm` remains the default Node package manager.
- `setup.sh zsh` ensures `zsh` is present, ensures it is allowed as a login
  shell, installs `starship`, `mise`, `zoxide`, `eza`, `bat`, `ripgrep`, and
  `openssl` from `apt`, makes zsh the default login shell when needed,
  syncs the repo zsh files into `~/.config/zsh`, synchronizes
  `~/.config/starship.toml`, writes a minimal `~/.zshenv` shim, and ensures
  history is stored at `~/.local/state/zsh/history`.
- The aliases in `config/zsh/aliases.zsh` include Podman-oriented container
  shortcuts such as `d`, `dc`, and `dps`. They are aliases for `podman`, not
  for Docker, and the repo does not currently install Podman or Docker for you.
- `setup.sh fzf`, `setup.sh fd`, `setup.sh direnv`, `setup.sh tlrc`, and
  `setup.sh pnpm` are optional explicit-request installs. They are not part of
  `setup.sh all`.
- `setup.sh all` runs every default step in order and excludes the optional
  explicit-request installs.
- If the core JetBrains Mono files already exist
  (`Regular`, `Bold`, `Italic`, and `BoldItalic`), the JetBrains Mono step
  treats that as already installed and skips package installation.
- Ghostty config is written to
  `${XDG_CONFIG_HOME:-~/.config}/com.mitchellh.ghostty/config.ghostty`.
- According to the official Ghostty binary installation docs, Ubuntu 26.04+
  provides `ghostty` in the official repositories. Older Ubuntu systems
  may need the community package from
  `https://github.com/mkasberg/ghostty-ubuntu`.
- On Ubuntu, some packages use distro-specific command names. The setup
  creates compatibility shims in `~/.local/bin` when needed, such as `bat` for
  `batcat` and `fd` for `fdfind`.
- If a required Ubuntu package is not available in the configured repositories,
  the step fails explicitly rather than trying to use Homebrew.

Ghostty base settings source:

- `config/ghostty/base.ghostty` is the file to edit when you want to change the
  Ghostty defaults.
- The Ghostty step overwrites
  `${XDG_CONFIG_HOME:-~/.config}/com.mitchellh.ghostty/config.ghostty` with the
  exact contents of that file.

zsh and Starship config sources:

- `config/zsh/.zshenv`, `config/zsh/.zshrc`, `config/zsh/aliases.zsh`, and
  `config/zsh/prompt.zsh` are the source files synchronized into
  `~/.config/zsh` by the zsh step.
- `config/starship.toml` is the source file synchronized into
  `~/.config/starship.toml` by the zsh step.

Git config source:

- `config/git/config` is the managed Git config synchronized into
  `~/.config/git/config` by the git step.

mise config source:

- `config/mise/config.toml` is the managed mise config synchronized into
  `~/.config/mise/config.toml` by the runtimes step.
