#!/bin/bash

# Define our colors 
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m' 
CYAN='\033[0;36m' 
RESET='\033[0m'

zoneinfo="Europe/London"
username="lee"

clear
echo
echo -e "${CYAN}  ###---------------------------------------------###${RESET}"
echo -e "${CYAN}  ###                                             ###${RESET}"
echo -e "${CYAN}  ###            Configuring timezones            ###${RESET}"
echo -e "${CYAN}  ###                                             ###${RESET}"
echo -e "${CYAN}  ###---------------------------------------------###${RESET}"
echo
ln -sf /usr/share/zoneinfo/$zoneinfo /etc/localtime
hwclock --systohc
###---------------------------------------------------------

clear
echo
echo -e "${CYAN} ###---------------------------------------------###"
echo "  ###                                             ###"
echo "  ###        Creating and Patching locales        ###"
echo "  ###                                             ###"
echo -e "  ###---------------------------------------------###${RESET}"
echo
sed -i 's/#en_gb.UTF/en_GB.UTF/' /etc/locale.gen
locale-gen
echo "LANG=en_GB.UTF-8" >> /etc/locale.conf
echo "KEYMAP=uk"  >> /etc/vconsole.conf
###---------------------------------------------------------

clear
echo
echo "  ###---------------------------------------------###"
echo "  ###                                             ###"
echo "  ###       Configuring hostname and hosts        ###"
echo "  ###                                             ###"
echo "  ###---------------------------------------------###"
echo
read -p 'Please enter a hostname for this device: ' hostname
echo $hostname >> /etc/hostname
### Create the hosts file
echo -e "127.0.0.1\tlocalhost" >> /etc/hosts
echo -e "::1\t\tlocalhost" >> /etc/hosts
echo -e "127.0.1.1\t$hostname.local\t$hostname" >> /etc/hosts
###---------------------------------------------------------

clear
echo
echo "  ###---------------------------------------------###"
echo "  ###                                             ###"
echo "  ###         Setting up users and groups         ###"
echo "  ###                                             ###"
echo "  ###---------------------------------------------###"
echo
useradd -m $username 
usermod -aG wheel,audio,video,optical,storage $username 
###---------------------------------------------------------

clear
echo
echo "  ###---------------------------------------------###"
echo "  ###                                             ###"
echo "  ###      Setting up root and user passwords     ###"
echo "  ###                                             ###"
echo "  ###---------------------------------------------###"
echo
echo "Please enter a password for the root account: "
passwd 
echo
echo "Please enter a password for the '$username' account: "
passwd $username 
###---------------------------------------------------------

clear
echo
echo "  ###---------------------------------------------###"
echo "  ###                                             ###"
echo "  ###      Updating the mirrorlist for pacman     ###"
echo "  ###                                             ###"
echo "  ###---------------------------------------------###"
echo
# I've had problems with this so may leave it out
#reflector --country "GB,FR,DE," --protocol https --sort rate --save /etc/pacman.d/mirrorlist
###---------------------------------------------------------

clear
echo
echo "  ###---------------------------------------------###"
echo "  ###                                             ###"
echo "  ###            Patching pacman.conf             ###"
echo "  ###                                             ###"
echo "  ###---------------------------------------------###"
echo
sed -i 's/#Color/Color/g' /etc/pacman.conf
###---------------------------------------------------------

#clear
echo "  ###---------------------------------------------###"
echo "  ###                                             ###"
echo "  ###            Updating package cache           ###"
echo "  ###                                             ###"
echo "  ###---------------------------------------------###"
echo
pacman -Syy 
###---------------------------------------------------------

#clear
echo
echo "  ###---------------------------------------------###"
echo "  ###                                             ###"
echo "  ###            Creating package lists           ###"
echo "  ###                                             ###"
echo "  ###---------------------------------------------###"
echo

yay_packages=()
pacman_packages=()
missing_packages=()

# use pacman -Qqe > packages.txt to create the starting
# list from our installed packages, edit as required.
readarray -t packages < packages.txt

for package in "${packages[@]}"; do
  if (pacman -Ss ${package} | grep -i ${package} > /dev/null); then
    echo -e "\e[1A\e[K$package found in the arch repository"
    pacman_packages+=("$package")
  else 
    if (yay -Ss ${package} | grep -i ${package} > /dev/null); then
      echo -e "\e[1A\e[K$package found in the user repository"
      yay_packages+=("$package")
    else 
      echo -e "${RED}$package not found in any repository${RESET}"
      missing_packages+=("$package")
    fi
  fi
done

if [ ${#pacman_packages[@]} -gt 0 ]; then
    echo "${pacman_packages[@]}" > pacman-packages.txt
fi

if [ ${#yay_packages[@]} -gt 0 ]; then
    echo "${yay_packages[@]}" > yay-packages.txt
fi

if [ ${#missing_packages[@]} -gt 0 ]; then
    echo "${missing_packages[@]}" > missing-packages.txt
fi
###---------------------------------------------------------

clear
echo
echo "  ###---------------------------------------------###"
echo "  ###                                             ###"
echo "  ###        Installing required packages         ###"
echo "  ###                                             ###"
echo "  ###---------------------------------------------###"
echo

cat /archinstaller/pacman-packages.txt | xargs pacman --noconfirm --needed -S
###---------------------------------------------------------

clear
echo
echo "  ###---------------------------------------------###"
echo "  ###                                             ###"
echo "  ### Setup yay and install required AUR packages ###"
echo "  ###                                             ###"
echo "  ###---------------------------------------------###"
echo
echo "This section requires user intervention"
read -p 'Press ENTER when ready...' pause
# Need some more testing on this section
# I can do everything but run makepkg as root 
# I'll re-run and check all paths are setup 
# and change permissions on yay directory
mkdir -p /home/$username/repos
cd /home/$username/repos
git clone https://aur.archlinux.org/yay-git.git 
chown -R $username yay-git
cd /home/$username/repos/yay-git
sudo -i -u $username bash << EOF 
makepkg -si 
EOF

cat /archinstaller/yay-packages.txt | xargs yay --noconfirm --needed -S
###---------------------------------------------------------

# Just pause it here so i can check the output from the above section
read -p 'Pause... ' pause

clear
echo
echo "  ###---------------------------------------------###"
echo "  ###                                             ###"
echo "  ###     Continue the rest of the setup here     ###"
echo "  ###                                             ###"
echo "  ###---------------------------------------------###"
echo 

###---------------------------------------------------------
exit

