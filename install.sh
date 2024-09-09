# Update zsh plugins and link .zshrc
pr=/Volumes/pr/dotfiles
git clone https://github.com/dracula/zsh-syntax-highlighting.git $pr/zsh/plugins/zsh-syntax-highlighting-dracula
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $pr/zsh/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions.git $pr/zsh/plugins/zsh-autosuggestions
rm ~/.zshrc
stow -d $pr/zsh/stow~ -t ~/ .
stow -d $pr/zsh/themes -t ~/.oh-my-zsh/themes .
stow -d $pr/zsh/plugins -t ~/.oh-my-zsh/plugins .

stow --adopt -d $pr/tmux/stow~ -t ~/ .

rm -rf ~/.config/nvim
mkdir ~/.config/nvim
stow -d $pr/nvim -t ~/.config/nvim .

stow -d $pr/dos -t ~/ .

git config --global core.excludesfile $pr/git/.gitignore

rm -rf ~/.config/colorls
mkdir ~/.config/colorls
mkdir $pr/colorls
git clone https://github.com/dracula/colorls.git $pr/colorls
cp $pr/colorls/dark_colors.yaml ~/.config/colorls/dark_colors.yaml

rm ~/.gdbinit
stow -d $pr/gdb/ -t ~/ .

rm ~/Library/Application\ Support/lazygit/config.yml
stow -d $pr/git/lazygit -t ~/Library/Application\ Support/lazygit .

rm ~/.ssh/config
stow -d $pr/ssh -t ~/.ssh .

rm -r ~/.warp
mkdir ~/.warp
stow -d $pr/warp -t ~/.warp .
