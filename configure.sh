#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m' 
CYAN='\033[0;36m' 
RESET='\033[0m'

timeout=10
zoneinfo="Europe/London"
username="lee"

clear
echo -e "${PURPLE}"
echo "###---------------------------------------------###"
echo "###                                             ###"
echo "###            Configuring timezones            ###"
echo "###                                             ###"
echo "###---------------------------------------------###"
echo -e "${RESET}"

ln -sf /usr/share/zoneinfo/$zoneinfo /etc/localtime
hwclock --systohc
sleep $timeout
###---------------------------------------------------------

clear
echo -e "${CYAN}"
echo "###---------------------------------------------###"
echo "###                                             ###"
echo "###        Creating and Patching locales        ###"
echo "###                                             ###"
echo "###---------------------------------------------###"
echo -e "${RESET}"

sed -i 's/#en_gb.UTF/en_GB.UTF/' /etc/locale.gen
locale-gen > /dev/null
echo "LANG=en_GB.UTF-8" >> /etc/locale.conf
echo "KEYMAP=uk"  >> /etc/vconsole.conf
sleep $timeout
###---------------------------------------------------------

clear
echo -e "${GREEN}"
echo "###---------------------------------------------###"
echo "###                                             ###"
echo "###       Configuring hostname and hosts        ###"
echo "###                                             ###"
echo "###---------------------------------------------###"
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
echo -e "${YELLOW}"
echo "###---------------------------------------------###"
echo "###                                             ###"
echo "###         Setting up users and groups         ###"
echo "###                                             ###"
echo "###---------------------------------------------###"
echo -e "${RESET}"

useradd -m $username 
usermod -aG wheel,audio,video,optical,storage $username 
sleep $timeout
###---------------------------------------------------------

clear
echo -e "${BLUE}"
echo "###---------------------------------------------###"
echo "###                                             ###"
echo "###      Setting up root and user passwords     ###"
echo "###                                             ###"
echo "###---------------------------------------------###"
echo -e "${RESET}"

echo "Please enter a password for the root account: "
passwd 
echo
echo "Please enter a password for the '$username' account: "
passwd $username 
sleep $timeout
###---------------------------------------------------------

clear
echo -e "${PURPLE}"
echo "###---------------------------------------------###"
echo "###                                             ###"
echo "###            Patching sudoers file            ###"
echo "###                                             ###"
echo "###---------------------------------------------###"
echo -e "${RESET}"

# I don't really like this method, I will come up with an alternative solution
#echo 's/^#\s*\(%wheel\s*ALL=(ALL)\s*ALL\)/\1/g' | EDITOR='sed -f- -i' visudo
sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers 
sleep $timeout
###---------------------------------------------------------

clear
echo -e "${CYAN}"
echo "###---------------------------------------------###"
echo "###                                             ###"
echo "###      Updating the mirrorlist for pacman     ###"
echo "###                                             ###"
echo "###---------------------------------------------###"
echo -e "${RESET}"

reflector --country "GB,FR,DE" --latest 100 --protocol https --sort rate --save /etc/pacman.d/mirrorlist 
sleep $timeout
###---------------------------------------------------------

clear
echo -e "${GREEN}"
echo "###---------------------------------------------###"
echo "###                                             ###"
echo "###                  Setup yay                  ###"
echo "###                                             ###"
echo "###---------------------------------------------###"
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
sudo -i -u $username bash -c "cd /home/$username/repos/yay-git && makepkg -si"
cd /archinstaller
sleep $timeout

clear
echo -e "${YELLOW}"
echo "###---------------------------------------------###"
echo "###                                             ###"
echo "###            Patching pacman.conf             ###"
echo "###                                             ###"
echo "###---------------------------------------------###"
echo -e "${RESET}"

sed -i 's/#Color/Color/g' /etc/pacman.conf
sed -i 's/#Verbose/Verbose/g' /etc/pacman.conf
sleep $timeout
###---------------------------------------------------------

clear
echo -e "${BLUE}"
echo "###---------------------------------------------###"
echo "###                                             ###"
echo "###            Updating package cache           ###"
echo "###                                             ###"
echo "###---------------------------------------------###"
echo -e "${RESET}"

pacman -Syy 
sleep $timeout
###---------------------------------------------------------

clear
echo -e "${PURPLE}"
echo "###---------------------------------------------###"
echo "###                                             ###"
echo "###            Creating package lists           ###"
echo "###                                             ###"
echo "###---------------------------------------------###"
echo -e "${RESET}"

comm -12 <(pacman -Slq | sort) <(sort packages.txt) > pacman-packages.txt
comm -23 <(sort packages.txt) <(pacman -Slq | sort) > aur-packages.txt
sleep $timeout
###---------------------------------------------------------

clear
echo -e "${CYAN}"
echo "###---------------------------------------------###"
echo "###                                             ###"
echo "###        Installing required packages         ###"
echo "###                                             ###"
echo "###---------------------------------------------###"
echo -e "${RESET}"

pacman --noconfirm --needed -S $(awk '{print $1}' /archinstaller/pacman-packages.txt)
sleep $timeout
###---------------------------------------------------------

clear
echo -e "${GREEN}"
echo "###---------------------------------------------###"
echo "###                                             ###"
echo "###               Enable services               ###"
echo "###                                             ###"
echo "###---------------------------------------------###"
echo -e "${RESET}"

systemctl enable bluetooth
systemctl enable NetworkManager

sleep $timeout
###---------------------------------------------------------

clear
echo -e "${YELLOW}"
echo "###---------------------------------------------###"
echo "###                                             ###"
echo "###      Install and configure systemd-boot     ###"
echo "###                                             ###"
echo "###---------------------------------------------###"
echo -e "${RESET}"

bootctl install

disk=$(<disk)
echo -e "timeout 0" >> /boot/loader/loader.conf
echo -e "console-mode keep" >> /boot/loader/loader.conf
echo -e "default arch.conf" >> /boot/loader/loader.conf

echo -e "title Arch Linux" >> /boot/loader/entries/arch.conf
echo -e "linux /vmlinuz-linux" >> /boot/loader/entries/arch.conf
echo -e "initrd /intel-ucode.img" >> /boot/loader/entries/arch.conf
echo -e "initrd /initramfs-linux.img" >> /boot/loader/entries/arch.conf
echo -e "options root=/dev/"$disk"3 rw quiet splash" >> /boot/loader/entries/arch.conf

echo -e "title Arch Linux (fallback initramfs)" >> /boot/loader/entries/arch-fallback.conf
echo -e "linux /vmlinuz-linux" >> /boot/loader/entries/arch-fallback.conf
echo -e "initrd /intel-ucode.img" >> /boot/loader/entries/arch-fallback.conf
echo -e "initrd /initramfs-linux-fallback.img" >> /boot/loader/entries/arch-fallback.conf
echo -e "options root=/dev/"$disk"3 rw quiet splash" >> /boot/loader/entries/arch-fallback.conf
sleep 20
###---------------------------------------------------------

clear
echo -e "${BLUE}"
echo "###---------------------------------------------###"
echo "###                                             ###"
echo "###   Creating temporary .profile and .bashrc   ###"
echo "###                                             ###"
echo "###---------------------------------------------###"
echo -e "${RESET}"

echo "[[ -f /archinstaller/run-once.sh ]] && bash -i /archinstaller/run-once.sh" > /home/$username/.profile
echo "[[ -f ~/.bashrc ]] && /. .bashrc" >> /home/$username/.profile

sleep $timeout
###---------------------------------------------------------
