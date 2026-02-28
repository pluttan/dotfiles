pr=/Volumes/pr/dotfiles
p=/Volumes/pr

export DISABLE_AUTO_TITLE='true'
export TERM="screen-256color"
export PATH=$PATH:~/.spoofdpi/bin
export PATH="$HOME/.tmuxifier/bin:$PATH"
export PATH="$PATH:/opt/nvim-linux64/bin"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="/opt/homebrew/bin/:$PATH"
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
sudo
composer
zsh-syntax-highlighting
zsh-autosuggestions
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

eval "$(starship init zsh)"

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
zstyle :omz:plugins:iterm2 shell-integration yes

ZSH_THEME="plam"

source $ZSH/oh-my-zsh.sh
source ~/.custom_aliases

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export PATH="/opt/X11/bin:$PATH"


if [ -f '/Users/pluttan/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/pluttan/google-cloud-sdk/path.zsh.inc'; fi

if [ -f '/Users/pluttan/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/pluttan/google-cloud-sdk/completion.zsh.inc'; fi


preexec_functions=()
precmd_functions=()


# Added by Antigravity
export PATH="/Users/pluttan/.antigravity/antigravity/bin:$PATH"

# bun completions
[ -s "/Users/pluttan/.bun/_bun" ] && source "/Users/pluttan/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

export PATH="$HOME/.local/bin:$PATH"

# opencode
export PATH=/Users/pluttan/.opencode/bin:$PATH

# tmuxp completions (disabled: tmuxp 1.64+ dropped click-based completions)
# eval "$(_TMUXP_COMPLETE=zsh_source tmuxp)"


alias zshreload="source ~/.zshrc"

# nb functions
source ~/.nbrc
