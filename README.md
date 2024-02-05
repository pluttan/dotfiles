# /home/pluttan/.dotfiles

This repo is the home of my custom system configuration which enables a consistent computing experience across multiple machines. Configure testing on mac os.

# Installation 

To install all dotfiles make sure that you have stow in your system.

Clone this repository to your userhome:

```bash
git clone https://github.com/pluttan/dotfiles.git "${XDG_CONFIG_HOME:-$HOME}"/.dotfiles
```

After that run installation script, that makes some symlinks in your home and .config dirs. 

```bash
~/.dotfiles/install.sh
```
