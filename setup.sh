#!/bin/bash

loadkeys uk 
timedatectl set-ntp true

lsblk | grep disk
read -p 'Enter the disk name: ' disk

# Create the partitions
# TODO: List all disks and give an option to do more than 1 disk
# TODO: Offer the ability to have /home on a separate drive

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

# Install required packages for a base install (we'll be installing more packages later)
pacstrap -K /mnt base linux linux-firmware base-devel git intel-ucode linux-headers reflector nano openssh awk

# Create the file table
genfstab -U /mnt >> /mnt/etc/fstab

# Copy the remaining scripts to a temporary directory
mkdir /mnt/archinstaller
cp configure.sh /mnt/archinstaller/

arch-chroot /mnt ./archinstaller/configure.sh