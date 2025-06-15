# Script should be powered by volumes for correct installation
# Volumes: https://github.com/pluttan/volumes

adduser --shell $(whereis zsh | awk '{print $2}') --gecos "" pluttan  ## Добавление пользователя pluttan \nВведите пароль пользователя pluttan 2 раза:
sudo usermod -aG sudo pluttan                                         #  Добавление pluttan в sudoers
{
    mkdir /home/pluttan/.system
    chown pluttan:pluttan /home/pluttan/.system
    chmod +rw pluttan:pluttan /home/pluttan/.system
    true                                     
} #  Выбор директории установки

{
    apt -y update
    apt -y upgrade
    apt -y full-upgrade
} ## Обновление системы

apt -y install zsh                             #  Установка zsh
apt -y install stow                            #  Установка stow
apt -y install python python3                  #  Установка python2
apt -y install build-essential                 #  Установка gcc
apt -y install ruby ruby-dev ruby-colorize     #  Установка ruby
apt -y install fonts-powerline fonts-firacode   #  Установка шрифтов
apt -y install git                             #  Установка git
apt -y install tmux                            #  Установка tmux
apt -y install curl                            #  Установка curl
apt -y install gdb                             #  Установка gdb

{
    cd /home/pluttan/.system
    rm -r /home/pluttan/.oh-my-zsh
    sudo -u pluttan RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
} # Установка oh-my-zsh

{
    sh -c "$(curl -sS https://starship.rs/install.sh)" -- -y
} # Установка starship

{
    cd /home/pluttan/.system
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
    chmod u+x nvim-linux-x86_64.appimage
    ./nvim-linux-x86_64.appimage --appimage-extract
    sudo mv squashfs-root/usr/bin/nvim /usr/local/bin/
    sudo rm -rf squashfs-root nvim-linux-x86_64.appimage
} # Установка nvim

gem install colorls # Установка colorls

{
    cd /home/pluttan/.system
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')/lazygit_$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit
    install lazygit -D -t /usr/local/bin/
} # Установка lazygit

{
    cd /home/pluttan/.system
    rm -r ./dotfiles
    sudo -u pluttan git clone https://github.com/pluttan/dotfiles 
    cp -r ./dotfiles /home/pluttan/.dotfiles
} # Клонирование dot-файлов

{
    sudo -u pluttan git clone https://github.com/dracula/zsh-syntax-highlighting.git /home/pluttan/.dotfiles/zsh/plugins/zsh-syntax-highlighting-dracula
    sudo -u pluttan git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /home/pluttan/.dotfiles/zsh/plugins/zsh-syntax-highlighting
    sudo -u pluttan git clone https://github.com/zsh-users/zsh-autosuggestions.git /home/pluttan/.dotfiles/zsh/plugins/zsh-autosuggestions
} # Настройка плагинов zsh

{
    sudo -u pluttan rm /home/pluttan/.zshrc
    sudo -u pluttan ln -s /home/pluttan/.dotfiles/zsh/lin/.custom_aliases /home/pluttan/ 
    sudo -u pluttan ln -s /home/pluttan/.dotfiles/zsh/lin/.zshrc /home/pluttan/ 
    sudo -u pluttan ln -s /home/pluttan/.dotfiles/zsh/themes /home/pluttan/.oh-my-zsh/themes
    sudo -u pluttan ln -s /home/pluttan/.dotfiles/zsh/plugins /home/pluttan/.oh-my-zsh/plugins
} # Настройка oh-my-zsh

{
    sudo -u pluttan rm /home/pluttan/.tmux.conf
    sudo -u pluttan ln -s /home/pluttan/.dotfiles/tmux/.tmux.conf /home/pluttan/ 
} # Настройка tmux

{
    sudo -u pluttan rm -rf /home/pluttan/.config/nvim
    sudo -u pluttan mkdir -p /home/pluttan/.config/nvim
    sudo -u pluttan ln -s /home/pluttan/.dotfiles/nvim /home/pluttan/.config/nvim
} # Настройка nvim

{
    sudo -u pluttan rm -r /home/pluttan/dos
    sudo -u pluttan ln -s /home/pluttan/.dotfiles/dos /home/pluttan/ 
} # Настройка dosbox

git config --global core.excludesfile /home/pluttan/.dotfiles/git/.gitignore # Настройка git

{
    sudo -u pluttan rm -rf /home/pluttan/.config/colorls
    sudo -u pluttan mkdir /home/pluttan/.config/colorls
    sudo -u pluttan mkdir /home/pluttan/.dotfiles/colorls
    sudo -u pluttan git clone https://github.com/dracula/colorls.git /home/pluttan/.dotfiles/colorls
    sudo -u pluttan ln -s /home/pluttan/.dotfiles/colorls/dark_colors.yaml /home/pluttan/.config/colorls/dark_colors.yaml
} # Настройка colorls

{
    sudo -u pluttan rm -r /home/pluttan/gdb
    sudo -u pluttan ln -s /home/pluttan/.dotfiles/gdb/ /home/pluttan/
} # Настройка gdb

{
    sudo -u pluttan rm -r /home/pluttan/.config/lazygit/
    sudo -u pluttan mkdir -p /home/pluttan/.config/lazygit/
    sudo -u pluttan ln -s /home/pluttan/.dotfiles/git/lazygit/ /home/pluttan/.config/lazygit/
} # Настройка lazygit

usermod -s $(whereis zsh | awk '{print $2}') pluttan # Настройка оболочки для pluttan

{
    mkdir /pr
    chown pluttan:pluttan /pr
} # Создание рабочей папки


{
    rm /home/pluttan/.system
    true                                     
} # Очистка директории установки
