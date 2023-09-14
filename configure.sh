#!/bin/bash

zoneinfo="Europe/London"
username="lee"

### Set zoneinfo and time
ln -sf /usr/share/zoneinfo/$zoneinfo /etc/localtime
hwclock -–systohc

### Create and Patch locales
sed -i 's/#en_gb.UTF/en_GB.UTF/' /etc/locale.gen
locale-gen
echo "LANG=en_GB.UTF-8" >> /etc/locale.conf
echo "KEYMAP=uk"  >> /etc/vconsole.conf
localectl set-x11-keymap gb

### Set the hostname
read -p 'Please enter a hostname for this device: ' hostname
echo $hostname >> /etc/hostname

### Create the hosts file
echo -e "127.0.0.1\tlocalhost" >> /etc/hosts
echo -e "::1\t\tlocalhost" >> /etc/hosts
echo -e "127.0.1.1\t$hostname.local\t$hostname" >> /etc/hosts

### Set the password for the root user
passwd 

### Create user account
useradd -m $username 
passwd $username 

### Add User to groups
usermod -aG wheel,audio,video,optical,storage $username 

### Update reflector
reflector --country "GB,FR,DE," --protocol https --sort rate --save /etc/pacman.d/mirrorlist

### Update pacman
pacman -Syy 

### Install other packages
pacman --noconfirm -S $(awk '{print $1}' required-packages-pacman)

### Setup yay

yay -Q $(awk '{print $1}' required-packages-yay)
