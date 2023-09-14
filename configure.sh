#!/bin/bash

zoneinfo="Europe/London"
username="lee"

clear
echo
echo "  ###---------------------------------------------###"
echo "  ###                                             ###"
echo "  ###            Configuring timezones            ###"
echo "  ###                                             ###"
echo "  ###---------------------------------------------###"
echo
ln -sf /usr/share/zoneinfo/$zoneinfo /etc/localtime
hwclock --systohc
###------------------------------------------------

clear
echo
echo "  ###---------------------------------------------###"
echo "  ###                                             ###"
echo "  ###        Creating and Patching locales        ###"
echo "  ###                                             ###"
echo "  ###---------------------------------------------###"
echo
sed -i 's/#en_gb.UTF/en_GB.UTF/' /etc/locale.gen
locale-gen
echo "LANG=en_GB.UTF-8" >> /etc/locale.conf
echo "KEYMAP=uk"  >> /etc/vconsole.conf
###----------------------------------------------

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
echo "  ###      Updating the mirrorlist for pacman     ###"
echo "  ###                                             ###"
echo "  ###---------------------------------------------###"
echo
#reflector --country "GB,FR,DE," --protocol https --sort rate --save /etc/pacman.d/mirrorlist

clear
echo
echo "  ###---------------------------------------------###"
echo "  ###                                             ###"
echo "  ###            Patching pacman.conf             ###"
echo "  ###                                             ###"
echo "  ###---------------------------------------------###"
echo
sed -i 's/#Color/Color/g' /etc/pacman.conf
###-------------------------------------------

#clear
echo "  ###---------------------------------------------###"
echo "  ###                                             ###"
echo "  ###            Updating package cache           ###"
echo "  ###                                             ###"
echo "  ###---------------------------------------------###"
echo
pacman -Syy 
###-------------------------------------------

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
RED='\033[0;31m'
RESET='\033[0m'

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

#clear
echo
echo "  ###---------------------------------------------###"
echo "  ###                                             ###"
echo "  ###        Installing required packages         ###"
echo "  ###                                             ###"
echo "  ###---------------------------------------------###"
echo

cat /archinstaller/pacman-packages.txt | xargs pacman --noconfirm --needed -S
###---------------------------------------------------------------

#clear
echo
echo "  ###---------------------------------------------###"
echo "  ###                                             ###"
echo "  ### Setup yay and install required AUR packages ###"
echo "  ###                                             ###"
echo "  ###---------------------------------------------###"
echo

sudo -i -u $username bash << EOF 
mkdir -p /home/$username/repos
sleep 3
cd /home/$username/repos
sleep 3
git clone https://aur.archlinux.org/yay.git 
cd /home/$username/repos/yay
sleep 3
makepkg -si 
EOF
#yay --noconfirm -S $(awk '{print $1}' /archinstaller/required-packages-yay)
cat /archinstaller/yay-packages.txt | xargs yay --noconfirm --needed -S
read -p 'Pause... ' pause

#clear
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
read -p 'Pause... ' pause
#clear
echo
echo "  ###---------------------------------------------###"
echo "  ###                                             ###"
echo "  ###     Continue the rest of the setup here     ###"
echo "  ###                                             ###"
echo "  ###---------------------------------------------###"

exit

