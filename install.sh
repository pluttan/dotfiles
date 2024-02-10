# Update zsh plugins and link .zshrc
rm -rf ~/.dotfiles/zsh/plugins
#git clone https://github.com/dracula/zsh-syntax-highlighting.git ~/.dotfiles/zsh/plugins/zsh-syntax-highlighting-dracula
#git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.dotfiles/zsh/plugins/zsh-syntax-highlighting
#git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.dotfiles/zsh/plugins/zsh-autosuggestions
rm ~/.zshrc
stow -d ~/.dotfiles/zsh/stow~ -t ~/ .

stow --adopt -d ~/.dotfiles/tmux/stow~ -t ~/ .

rm -rf ~/.config/nvim
mkdir ~/.config/nvim
stow --adopt -d ~/.dotfiles/nvim -t ~/.config/nvim .

stow --adopt -d ~/.dotfiles/dos -t ~/ .

git config --global core.excludesfile ~/.dotfiles/git/.gitignore

rm ~/.config/lazygit/config.yml
stow --adopt -d ~/.dotfiles/git/lazygit -t ~/.config/lazygit .
