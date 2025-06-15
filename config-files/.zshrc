# Enable Powerlevel10k instant prompt (must stay at the very top)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Setup environment
export TERM=xterm-256color
export EDITOR=nvim
export VISUAL=nvim

# PATH settings
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/mysql/bin:$HOME/.local/bin:/Users/azeem/.spicetify:$PATH"

# iTerm2 shell integration
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# Zsh plugins
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
# plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
# source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /Users/azeem/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# NVM (Node Version Manager)
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# DBUS (for desktop session communication, probably safe to keep)
export DBUS_SESSION_BUS_ADDRESS="unix:path=$DBUS_LAUNCHD_SESSION_BUS_SOCKET"

# Powerlevel10k Theme
source ~/powerlevel10k/powerlevel10k.zsh-theme

# Powerlevel10k Prompt Configuration
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

