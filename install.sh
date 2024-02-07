# Update zsh plugins and link .zshrc
rm -rf ~/.dotfiles/zsh/plugins
git clone https://github.com/dracula/zsh-syntax-highlighting.git ~/.dotfiles/zsh/plugins/zsh-syntax-highlighting-dracula
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.dotfiles/zsh/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.dotfiles/zsh/plugins/zsh-autosuggestions
stow -d ~/.dotfiles/zsh/stow~ -t ~/ .

stow -d ~/.dotfiles/tmux/stow~ -t ~/ .

mkdir ~/.config/nvim
stow -d ~/.dotfiles/nvim -t ~/.config/nvim .

stow -d ~/.dotfiles/dos -t ~/ .

git config --global core.excludesfile ~/.dotfiles/git/.gitignore

rm ~/Library/Application\ Support/lazygit/config.yml
stow -d ~/.dotfiles/git/lazygit -t ~/Library/Application\ Support/lazygit .
