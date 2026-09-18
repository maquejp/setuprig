# setuprig

This repo is being built step by step for macOS.

Current steps:

1. Ensure Homebrew is installed.
2. Ensure JetBrains Mono is installed.
3. Ensure Ghostty is installed with Homebrew and apply the base Ghostty
  settings.
4. Ensure Xcode Command Line Tools are installed.
5. Ensure Git tooling is installed and the managed Git config is active.
6. Ensure the default CLI tools are installed.
7. Ensure the managed runtime baseline is installed with mise.
8. Ensure zsh is present and the default login shell.

Optional steps can install extra tools only when you request them.

Current scope covers terminal bootstrap, developer CLI tooling, Git/GitHub
tooling, and a minimal runtime baseline for macOS. Optional tools stay out of
the default path until you request them.

Usage:

```bash
bash setup.sh homebrew
bash setup.sh jetbrains-mono
bash setup.sh ghostty
bash setup.sh xcode-cli
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

- `setup.sh homebrew` ensures Homebrew is present.
- `setup.sh jetbrains-mono` ensures Homebrew is present, then installs the
  `font-jetbrains-mono` cask if needed.
- `setup.sh ghostty` ensures Homebrew is present, then installs the `ghostty`
  cask if needed and writes your base settings to
  `~/Library/Application Support/com.mitchellh.ghostty/config.ghostty`.
- `setup.sh xcode-cli` verifies that Xcode Command Line Tools are installed. If
  they are missing, it triggers the standard macOS installer flow and asks you
  to rerun the step after installation completes.
- `setup.sh git` ensures Homebrew and Xcode Command Line Tools are present,
  installs `gh` and `git-delta`, treats an existing system `git` from macOS or
  Xcode Command Line Tools as sufficient, installs Homebrew `git` only if `git`
  is otherwise missing, synchronizes the managed Git config to
  `~/.config/git/config`, and ensures `~/.gitconfig` includes that managed
  config without overwriting existing user settings.
- `setup.sh cli-tools` ensures Homebrew and Xcode Command Line Tools are
  present, then installs the default CLI tools: `jq`, `yq`, and `tmux`.
- `setup.sh runtimes` ensures Homebrew and Xcode Command Line Tools are
  present, ensures `mise` is installed, synchronizes
  `~/.config/mise/config.toml`, and installs the managed runtime baseline:
  Node LTS and Python 3. `npm` remains the default Node package manager.
- `setup.sh zsh` ensures `/bin/zsh` exists, ensures it is allowed as a login
  shell, installs `starship`, `mise`, `zoxide`, `eza`, `bat`, `ripgrep`, and
  `openssl@3` with Homebrew when needed, makes zsh the default login shell
  when needed, syncs the repo zsh files into `~/.config/zsh`, synchronizes
  `~/.config/starship.toml`, writes a minimal `~/.zshenv` shim, and ensures
  history is stored at `~/.local/state/zsh/history`.
- `setup.sh fzf`, `setup.sh fd`, `setup.sh direnv`, `setup.sh tlrc`, and
  `setup.sh pnpm` are optional explicit-request installs. They are not part of
  `setup.sh all`.
- `setup.sh all` runs every default step in order and excludes the optional
  explicit-request installs.
- If the core JetBrains Mono files already exist outside Homebrew
  (`Regular`, `Bold`, `Italic`, and `BoldItalic`), the JetBrains Mono step
  treats that as already installed and skips Homebrew installation.
- If `Ghostty.app` already exists in `/Applications` outside Homebrew, the
  Ghostty step treats that as already installed, skips Homebrew installation,
  and still overwrites the Ghostty config with your base settings.

Ghostty base settings source:

- `config/ghostty/base.ghostty` is the file to edit when you want to change the
  Ghostty defaults.
- The Ghostty step overwrites
  `~/Library/Application Support/com.mitchellh.ghostty/config.ghostty` with the
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
