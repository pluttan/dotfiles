 #[[ -f "${HOME}/Library/Application Support/codewhisperer/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/codewhisperer/shell/zshrc.pre.zsh"

export TERM="screen-256color"
export PATH="$HOME/.tmuxifier/bin:$PATH"
export PATH="$PATH:/opt/nvim-linux64/bin"
export PATH="$HOME/.cargo/bin:$PATH"
export NVM_DIR="$HOME/.nvm"
export MANPAGER='nvim +Man!'
export EDITOR=nvim
export ZSH="$HOME/.oh-my-zsh"
ZSH_CUSTOM="${HOME}/.dotfiles/zsh"

source ~/.dotfiles/zsh/plugins/zsh-syntax-highlighting-dracula/zsh-syntax-highlighting.sh

plugins=(git
colorize
#Docker
sudo
composer
zsh-syntax-highlighting
zsh-autosuggestions
#autoedit
aliases
brew
command-not-found
compleat
dirhistory
emoji-clock
iterm2
macos
python
tmux
)

[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  

#eval $(thefuck --alias)
#eval $(thefuck --alias FUCK)

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
zstyle :omz:plugins:iterm2 shell-integration yes

ZSH_THEME="plam"

source $ZSH/oh-my-zsh.sh
source ~/.dotfiles/zsh/stow\~/.custom_aliases
if ! {  [ -n "$TMUX" ] } then
    eval "tmux"
fi
