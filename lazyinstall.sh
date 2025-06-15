wget https://raw.githubusercontent.com/pluttan/dotfiles/refs/heads/main/installnew.sh
chmod +x volumes.sh
sh -c "$(wget -O- https://raw.githubusercontent.com/pluttan/volumes/main/volumes.sh)" -- installnew.sh
rm installnew.sh
