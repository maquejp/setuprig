# setuprig

This repo is being built step by step for macOS.

Current steps:

1. Ensure Homebrew is installed.
2. Ensure JetBrains Mono is installed.
3. Ensure Ghostty is installed with Homebrew and apply the base Ghostty
  settings.

Current scope stops at Homebrew, JetBrains Mono, Ghostty installation, and
your base Ghostty settings. Nothing here configures zsh, defaults, or any
later setup until you ask for the next step.

Usage:

```bash
bash setup.sh homebrew
bash setup.sh jetbrains-mono
bash setup.sh ghostty
bash setup.sh all
```

Notes:

- `setup.sh homebrew` ensures Homebrew is present.
- `setup.sh jetbrains-mono` ensures Homebrew is present, then installs the
  `font-jetbrains-mono` cask if needed.
- `setup.sh ghostty` ensures Homebrew is present, then installs the `ghostty`
  cask if needed and writes your base settings to
  `~/Library/Application Support/com.mitchellh.ghostty/config.ghostty`.
- `setup.sh all` runs every currently implemented step in order.
- If JetBrains Mono font files already exist outside Homebrew, the
  JetBrains Mono step treats that as already installed and skips Homebrew
  installation.
- If `Ghostty.app` already exists in `/Applications` outside Homebrew, the
  Ghostty step treats that as already installed, skips Homebrew installation,
  and still overwrites the Ghostty config with your base settings.

Ghostty base settings source:

- `config/ghostty/base.ghostty` is the file to edit when you want to change the
  Ghostty defaults.
- The Ghostty step overwrites
  `~/Library/Application Support/com.mitchellh.ghostty/config.ghostty` with the
  exact contents of that file.
