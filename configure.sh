#!/bin/bash

zoneinfo="Europe/London"
username="lee"

clear
echo "###-----------------------###"
echo "### Configuring timezones ###"
echo "###-----------------------###"

ln -sf /usr/share/zoneinfo/$zoneinfo /etc/localtime
hwclock --systohc
###------------------------------------------------


clear
echo "###-------------------------------###"
echo "### Creating and Patching locales ###"
echo "###-------------------------------###"

sed -i 's/#en_gb.UTF/en_GB.UTF/' /etc/locale.gen
locale-gen
echo "LANG=en_GB.UTF-8" >> /etc/locale.conf
echo "KEYMAP=uk"  >> /etc/vconsole.conf
localectl set-x11-keymap gb
###----------------------------------------------

clear
echo "###--------------------------------###"
echo "### Configuring hostname and hosts ###"
echo "###--------------------------------###"

read -p 'Please enter a hostname for this device: ' hostname
echo $hostname >> /etc/hostname

### Create the hosts file
echo -e "127.0.0.1\tlocalhost" >> /etc/hosts
echo -e "::1\t\tlocalhost" >> /etc/hosts
echo -e "127.0.1.1\t$hostname.local\t$hostname" >> /etc/hosts

clear
echo "###-----------------------------###"
echo "### Setting up users and groups ###"
echo -e "###-----------------------------###\n"

echo "Please enter a password for the root account: "
passwd 

useradd -m $username 
echo "Please enter a password for the '$username' account: "
passwd $username 
usermod -aG wheel,audio,video,optical,storage $username 
###---------------------------------------------------------

clear
echo "###----------------------------------###"
echo "### Update the mirrorlist for pacman ###"
echo "###----------------------------------###"

reflector --country "GB,FR,DE," --protocol https --sort rate --save /etc/pacman.d/mirrorlist

clear
echo "###---------------------------------###"
echo "### Update package cache for pacman ###"
echo "###---------------------------------###"

pacman -Syy 
###-------------------------------------------

clear
echo "###---------------------------###"
echo "### Install required packages ###"
echo "###---------------------------###"

pacman --noconfirm -S $(awk '{print $1}' required-packages-pacman)
###---------------------------------------------------------------

clear
echo "###---------------------------------------------###"
echo "### Setup yay and install required AUR packages ###"
echo "###---------------------------------------------###"

yay --noconfirm -S $(awk '{print $1}' required-packages-yay)
