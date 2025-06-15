pr=/home/pluttan/dotfiles
p=/Volumes/pr

export TERM="screen-256color"
export PATH="$HOME/.tmuxifier/bin:$PATH"
export PATH="$PATH:/opt/nvim-linux64/bin"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$PATH:$HOME/.npm-global/bin"
export PATH="$GowinHome/IDE/bin:$GowinHome/Programmer:$PATH"
export GEM_PATH="$HOME/.npm-global/bin"
export NVM_DIR="$HOME/.nvm"
export MANPAGER='nvim +Man!'
export EDITOR=nvim
export ZSH="$HOME/.oh-my-zsh"
export GowinHome="/opt/gowin"
export LD_LIBRARY_PATH="$GowinHome/IDE/lib:$LD_LIBRARY_PATH"
ZSH_CUSTOM="${HOME}/.dotfiles/zsh"

source $pr/zsh/plugins/zsh-syntax-highlighting-dracula/zsh-syntax-highlighting.sh

plugins=(git
colorize
#Docker
sudo
composer
zsh-syntax-highlighting
zsh-autosuggestions
#autoedit
aliases
command-not-found
compleat
dirhistory
emoji-clock
python
tmux
)

[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  

# eval "$(starship init zsh)"

ZSH_THEME="plam"

source $ZSH/oh-my-zsh.sh
source $HOME/.custom_aliases

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export PATH="/opt/X11/bin:$PATH"

