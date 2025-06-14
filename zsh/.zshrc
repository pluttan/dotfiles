pr=/Volumes/pr/dotfiles
p=/Volumes/pr

export TERM="screen-256color"
export PATH="$HOME/.tmuxifier/bin:$PATH"
export PATH="$PATH:/opt/nvim-linux64/bin"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="/opt/homebrew/bin/:$PATH"
# export PATH="$HOME/.rvm/rubies/ruby-3.0.1/bin/:$PATH"
export PATH="$PATH:/Applications/ArmGNUToolchain/13.2.Rel1/arm-none-eabi/bin"
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
eval "$(starship init zsh)"

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
zstyle :omz:plugins:iterm2 shell-integration yes

ZSH_THEME="plam"

source $ZSH/oh-my-zsh.sh
source $pr/zsh/stow\~/.custom_aliases
# if ! {  [ -n "$TMUX" ] } then
#     eval "tmux"
# fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export PATH="/opt/X11/bin:$PATH"

