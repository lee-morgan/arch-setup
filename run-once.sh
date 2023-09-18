#!/bin/bash 

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m' 
CYAN='\033[0;36m' 
RESET='\033[0m'

timeout=1

clear
echo -e "${PURPLE}"
echo "###---------------------------------------------###"
echo "###                                             ###"
echo "###                  Setup yay                  ###"
echo "###                                             ###"
echo "###---------------------------------------------###"
echo -e "${RESET}"

mkdir -p $HOME/repos
cd $HOME/repos
git clone https://aur.archlinux.org/yay-bin.git 
cd $HOME/repos/yay-bin 
makepkg -si
cd $HOME
sleep $timeout

clear
echo -e "${CYAN}"
echo "###---------------------------------------------###"
echo "###                                             ###"
echo "###            Install yay packages             ###"
echo "###                                             ###"
echo "###---------------------------------------------###"
echo -e "${RESET}"

yay --needed -S $(awk '{print $1}' /archinstaller/aur-packages.txt) 
sleep $timeout
###---------------------------------------------------------

clear
echo -e "${GREEN}"
echo "###---------------------------------------------###"
echo "###                                             ###"
echo "###            Install pita packages            ###"
echo "###                                             ###"
echo "###---------------------------------------------###"
echo -e "${RESET}"

# These are all packages that require confirming conflicts.
sudo pacman --needed -S $(awk '{print $1}' /archinstaller/pita-packages.txt)

clear 
echo -e "${YELLOW}"
echo "###---------------------------------------------###"
echo "###                                             ###"
echo "###                Clone dotfiles               ###"
echo "###                                             ###"
echo "###---------------------------------------------###"
echo -e "${RESET}"

rm -rf $HOME/.bashrc $HOME/.bash_profile $HOME/.bash_logout
git clone --bare https://github.com/lee-morgan/dotfiles-git.git $HOME/dotfiles-git
alias dtf='/usr/bin/git --git-dir=$HOME/dotfiles-git/ --work-tree=$HOME'
dtf checkout 

clear
echo -e "${BLUE}"
echo "###---------------------------------------------###"
echo "###                                             ###"
echo "###             Enable user services            ###"
echo "###                                             ###"
echo "###---------------------------------------------###"
echo -e "${RESET}"

systemctl --user enable --now pipewire  
systemctl --user enable --now pipewire-pulse 
systemctl --user enable --now wireplumber
sudo systemctl enable sddm 
sudo ststemctl enable libvirtd
sudo usermod -aG libvirt $USER

clear 
echo -e "${PURPLE}"
echo "###---------------------------------------------###"
echo "###                                             ###"
echo "###            Cleanup setup scripts            ###"
echo "###                                             ###"
echo "###---------------------------------------------###"
echo -e "${RESET}"

sudo rm -rf /archinstaller

###---------------------------------------------------------
