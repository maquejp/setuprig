# setuprig

Step 1 only: ensure Homebrew is installed on macOS.

This repo is being built step by step. The current script only handles
Homebrew and does not move on to Ghostty, zsh, or any other setup until you
ask for the next step.

Usage:

```bash
bash setup-homebrew.sh
```

If Homebrew is already installed, the script exits successfully. If it is
missing, the script installs it with the official Homebrew installer.
