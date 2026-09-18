# setuprig

This repo is being built step by step for macOS.

Current steps:

1. Ensure Homebrew is installed.
2. Ensure JetBrains Mono is installed.
3. Ensure Ghostty is installed with Homebrew and apply the base Ghostty
  settings.
4. Ensure zsh is present and the default login shell.

Current scope stops at Homebrew, JetBrains Mono, Ghostty installation, and
your base Ghostty settings plus the login shell. Nothing here configures other
defaults or any later setup until you ask for the next step.

Usage:

```bash
bash setup.sh homebrew
bash setup.sh jetbrains-mono
bash setup.sh ghostty
bash setup.sh zsh
bash setup.sh all
```

Notes:

- `setup.sh homebrew` ensures Homebrew is present.
- `setup.sh jetbrains-mono` ensures Homebrew is present, then installs the
  `font-jetbrains-mono` cask if needed.
- `setup.sh ghostty` ensures Homebrew is present, then installs the `ghostty`
  cask if needed and writes your base settings to
  `~/Library/Application Support/com.mitchellh.ghostty/config.ghostty`.
- `setup.sh zsh` ensures `/bin/zsh` exists, ensures it is allowed as a login
  shell, installs `starship`, `mise`, `zoxide`, `eza`, `bat`, `ripgrep`, and
  `openssl@3` with Homebrew when needed, makes zsh the default login shell
  when needed, syncs the repo zsh files into `~/.config/zsh`, synchronizes
  `~/.config/starship.toml`, writes a minimal `~/.zshenv` shim, and ensures
  history is stored at `~/.local/state/zsh/history`.
- `setup.sh all` runs every currently implemented step in order.
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
