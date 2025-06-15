wget https://raw.githubusercontent.com/pluttan/dotfiles/refs/heads/main/installnew.sh
wget https://raw.githubusercontent.com/pluttan/volumes/refs/heads/main/volumes.sh
chmod +x volumes.sh
sh -c "$(./volumes.sh)" -- installnew.sh
rm installnew.sh volumes.sh