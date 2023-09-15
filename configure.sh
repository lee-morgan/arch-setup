#!/bin/bash

# Define our colors 
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m' 
CYAN='\033[0;36m' 
RESET='\033[0m'

timeout=2
zoneinfo="Europe/London"
username="lee"

clear
echo -e "${CYAN}"
echo "  ###---------------------------------------------###"
echo "  ###                                             ###"
echo "  ###            Configuring timezones            ###"
echo "  ###                                             ###"
echo "  ###---------------------------------------------###"
echo -e "${RESET}"

ln -sf /usr/share/zoneinfo/$zoneinfo /etc/localtime
hwclock --systohc
sleep $timeout
###---------------------------------------------------------

clear
echo -e "${CYAN}"
echo "  ###---------------------------------------------###"
echo "  ###                                             ###"
echo "  ###        Creating and Patching locales        ###"
echo "  ###                                             ###"
echo "  ###---------------------------------------------###"
echo -e "${RESET}"

sed -i 's/#en_gb.UTF/en_GB.UTF/' /etc/locale.gen
locale-gen
echo "LANG=en_GB.UTF-8" >> /etc/locale.conf
echo "KEYMAP=uk"  >> /etc/vconsole.conf
sleep $timeout
###---------------------------------------------------------

clear
echo -e "${CYAN}"
echo "  ###---------------------------------------------###"
echo "  ###                                             ###"
echo "  ###       Configuring hostname and hosts        ###"
echo "  ###                                             ###"
echo "  ###---------------------------------------------###"
echo -e "${RESET}"

read -p 'Please enter a hostname for this device: ' hostname
echo $hostname >> /etc/hostname
### Create the hosts file
echo -e "127.0.0.1\tlocalhost" >> /etc/hosts
echo -e "::1\t\tlocalhost" >> /etc/hosts
echo -e "127.0.1.1\t$hostname.local\t$hostname" >> /etc/hosts
sleep $timeout
###---------------------------------------------------------

clear
echo -e "${CYAN}"
echo "  ###---------------------------------------------###"
echo "  ###                                             ###"
echo "  ###         Setting up users and groups         ###"
echo "  ###                                             ###"
echo "  ###---------------------------------------------###"
echo -e "${RESET}"

useradd -m $username 
usermod -aG wheel,audio,video,optical,storage $username 
sleep $timeout
###---------------------------------------------------------

clear
echo -e "${CYAN}"
echo "  ###---------------------------------------------###"
echo "  ###                                             ###"
echo "  ###      Setting up root and user passwords     ###"
echo "  ###                                             ###"
echo "  ###---------------------------------------------###"
echo -e "${RESET}"

echo "Please enter a password for the root account: "
passwd 
echo
echo "Please enter a password for the '$username' account: "
passwd $username 
sleep $timeout
###---------------------------------------------------------

clear
echo -e "${CYAN}"
echo "  ###---------------------------------------------###"
echo "  ###                                             ###"
echo "  ###            Patching sudoers file            ###"
echo "  ###                                             ###"
echo "  ###---------------------------------------------###"
echo -e "${RESET}"

# I don't really like this method, I will come up with an alternative solution
#echo 's/^#\s*\(%wheel\s*ALL=(ALL)\s*ALL\)/\1/g' | EDITOR='sed -f- -i' visudo
sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL(ALL:ALL) ALL' /etc/sudoers 
read -p 'Pause... ' pause
cat /etc/sudoers
sleep $timeout
###---------------------------------------------------------

#clear
echo -e "${CYAN}"
echo "  ###---------------------------------------------###"
echo "  ###                                             ###"
echo "  ###      Updating the mirrorlist for pacman     ###"
echo "  ###                                             ###"
echo "  ###---------------------------------------------###"
echo -e "${RESET}"

# I've had problems with this so may leave it out
#reflector --country "GB,FR,DE," --protocol https --sort rate --save /etc/pacman.d/mirrorlist 
sleep $timeout
###---------------------------------------------------------

#clear
echo -e "${CYAN}"
echo "  ###---------------------------------------------###"
echo "  ###                                             ###"
echo "  ###                  Setup yay                  ###"
echo "  ###                                             ###"
echo "  ###---------------------------------------------###"
echo -e "${RESET}"

echo "This section requires user intervention"
read -p 'Press ENTER when ready to continue...' pause
# Need some more testing on this section
# I can do everything but run makepkg as root 
# I'll re-run and check all paths are setup 
# and change permissions on yay directory
mkdir -p /home/$username/repos
cd /home/$username/repos
git clone https://aur.archlinux.org/yay-git.git 
chown -R $username:$username yay-git
sudo -i -u $username bash << EOF 
cd /home/$username/repos/yay-git
makepkg -si 
EOF
cd /archinstaller
sleep $timeout

#clear
echo -e "${CYAN}"
echo "  ###---------------------------------------------###"
echo "  ###                                             ###"
echo "  ###            Patching pacman.conf             ###"
echo "  ###                                             ###"
echo "  ###---------------------------------------------###"
echo -e "${RESET}"

sed -i 's/#Color/Color/g' /etc/pacman.conf
sleep $timeout
###---------------------------------------------------------

#clear
echo -e "${CYAN}"
echo "  ###---------------------------------------------###"
echo "  ###                                             ###"
echo "  ###            Updating package cache           ###"
echo "  ###                                             ###"
echo "  ###---------------------------------------------###"
echo -e "${RESET}"

pacman -Syy 
yay -Syy
sleep $timeout
###---------------------------------------------------------

#clear
echo -e "${CYAN}"
echo "  ###---------------------------------------------###"
echo "  ###                                             ###"
echo "  ###            Creating package lists           ###"
echo "  ###                                             ###"
echo "  ###---------------------------------------------###"
echo -e "${RESET}"

yay_packages=()
pacman_packages=()
missing_packages=()

# use pacman -Qqe > packages.txt to create the starting
# list from our installed packages, edit as required.
readarray -t packages < /archinstaller/packages.txt

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
sleep $timeout
###---------------------------------------------------------

#clear
echo -e "${CYAN}"
echo "  ###---------------------------------------------###"
echo "  ###                                             ###"
echo "  ###        Installing required packages         ###"
echo "  ###                                             ###"
echo "  ###---------------------------------------------###"
echo -e "${RESET}"

cat /archinstaller/pacman-packages.txt | xargs pacman --noconfirm --needed -S
sleep $timeout
###---------------------------------------------------------

#clear
echo -e "${CYAN}"
echo "  ###---------------------------------------------###"
echo "  ###                                             ###"
echo "  ###            Install yay packages             ###"
echo "  ###                                             ###"
echo "  ###---------------------------------------------###"
echo -e "${RESET}"

cat /archinstaller/yay-packages.txt | xargs yay --noconfirm --needed -S
sleep $timeout
###---------------------------------------------------------

# Just pause it here so i can check the output from the above section
read -p 'Pause... ' pause

clear
echo -e "${CYAN}"
echo "  ###---------------------------------------------###"
echo "  ###                                             ###"
echo "  ###     Continue the rest of the setup here     ###"
echo "  ###                                             ###"
echo "  ###---------------------------------------------###"
echo -e "${RESET}"

sleep $timeout
###---------------------------------------------------------
exit

