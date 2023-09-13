#!/bin/bash

loadkeys uk 
timedatectl set-ntp true

lsblk | grep disk
read -p 'Enter the disk name: ' disk
# Create the partitions
echo "Creating 4 partitions"
(echo g
echo n; echo 1; echo ; echo '+550M'
echo n; echo 2; echo ; echo '+2G'
echo n; echo 3; echo ; echo '+20G' 
echo n; echo 4; echo ; echo 
echo t; echo 1; echo 1
echo t; echo 2; echo 19
echo w) | fdisk /dev/$disk

### Format the partitions 
mkfs.fat -F32 /dev/"$disk"1 # EFI
mkswap /dev/"$disk"2 # SWAP 
mkfs.ext4 /dev/"$disk"3 # /
mkfs.ext4 /dev/"$disk"4 # /home

### Mount the partitions
mount /dev/"$disk"3 /mnt
mount --mkdir /dev/"$disk"1 /mnt/boot
mount --mkdir /dev/"$disk"4 /mnt/home

### Enable the SWAP partition
swapon /dev/"$disk"2 

# Install required packages
pacstrap -K /mnt base linux linux-firmware networkmanager nano sudo

# Create the file table
genfstab -U /mnt >> /mnt/etc/fstab

# Copy the remaining scripts to a temporary directory
mkdir /mnt/archinstall 
cp config.sh /mnt/archinstall/

arch-chroot /mnt ./archinstall/config.sh

ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime
hwclock –systohc
sed -i 's/#en_gb.UTF/en_GB.UTF/' /etc/loacale.gen
locale-gen
echo "LANG=en_GB.UTF-8" >> /etc/locale.conf
echo "KEYMAP=uk"  >> /etc/vconsole.conf

### Set the hostname
read -p 'Please enter a hostname for this device: ' hostname
echo $hostname >> /etc/hostname

echo -e "127.0.0.1\tlocalhost" >> /etc/hosts
echo -e "::1\t\tlocalhost" >> /etc/hosts
echo -e "127.0.1.1\t$hostname.local\t$hostname" >> /etc/hosts

### We need to enable services here



