# Better ls
alias l='eza -lh --icons'
alias ls='eza --icons'

# Detailed listing
alias ll='eza -lh --icons --git'

# Detailed listing including hidden files
alias la='eza -lah --icons --git'

# Tree view
alias tree='eza --tree --icons'

compdef eza=ls

# === GIT ALIASES ===
alias g='git'
alias ga='git add'
alias gaa='git add .'
alias gau='git add -u'
alias gb='git branch'
alias gbd='git branch -d'
alias gbD='git branch -D'
alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit --amend'
alias gcan='git commit --amend --no-edit'
alias gco='git checkout'
alias gcob='git checkout -b'
alias gd='git diff'
alias gdm='git diff main'
alias gds='git diff --staged'
alias gf='git fetch'
alias gfp='git fetch && git pull'
alias gl='git log --oneline -10'
alias glg='git log --all --graph --oneline --decorate'
alias gm='git merge'
alias gmm='git merge main'
alias gp='git pull'
alias gps='git push'
alias gpsu='git push -u origin HEAD'
alias grb='git rebase'
alias grbm='git rebase main'
alias gr='git restore'
alias grs='git restore --staged'
alias gst='git stash'
alias gstp='git stash pop'
alias gstl='git stash list'

# === PODMAN ALIASES ===
alias d='podman'
alias dc='podman compose'
alias dcu='podman compose up'
alias dcud='podman compose up -d'
alias dcd='podman compose down'
alias dcl='podman compose logs'
alias dclf='podman compose logs -f'
alias dcrb='podman compose restart'
alias dps='podman ps'
alias dpsa='podman ps -a'
alias dim='podman images'
alias drm='podman rm'
alias drmi='podman rmi'
alias db='podman build'
alias dex='podman exec -it'
alias dil='podman image ls'
alias dvl='podman volume ls'

# === NAVIGATION ===
alias ~='cd ~'
alias ..='cd ..'
alias ...='cd ../../'
alias cd-='cd -'

# === COMMON UTILITIES ===
alias c='clear'
alias cat='bat'
alias mkdir='mkdir -p'
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias grep='rg --color=auto'
alias du='du -sh'
alias df='df -h'

# === NODE/NPM ALIASES ===
alias npm-global='npm list -g --depth=0'
alias ni='npm install'
alias nid='npm install --save-dev'
alias nr='npm run'
alias ns='npm start'
alias nt='npm test'

# === DIRECTORIES ===
alias dev='cd ~/Developer'
alias proj='cd ~/Developer/Projects'
alias config='cd ~/.config'