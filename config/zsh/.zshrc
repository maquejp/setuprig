if [[ -n "${HOMEBREW_PREFIX:-}" ]]; then
	export PATH="${HOMEBREW_PREFIX}/opt/openssl/bin:$PATH"
fi

eval "$(mise activate zsh)"


# =========================================================
# History
# =========================================================

HISTFILE="$XDG_STATE_HOME/zsh/history"
HISTSIZE=100000
SAVEHIST=100000

setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS

# =========================================================
# Shell behaviour
# =========================================================

setopt AUTOCD
setopt NOBEEP
setopt NUMERIC_GLOB_SORT

eval "$(zoxide init zsh)"

if command -v direnv >/dev/null 2>&1; then
	eval "$(direnv hook zsh)"
fi

# =========================================================
# Completion
# =========================================================

autoload -Uz compinit
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump"

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

source "$ZDOTDIR/aliases.zsh"
source "$ZDOTDIR/prompt.zsh"