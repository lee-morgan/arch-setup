#!/bin/bash

loadkeys uk 
timedatectl set-ntp true

clear
echo "###---------------------###"
echo "### Creating partitions ###"
echo "###---------------------###"
lsblk | grep disk | awk '{print $1}'
read -p 'Enter the disk name: ' disk

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
###---------------------------------

clear
echo "###-----------------------###"
echo "### Formatting partitions ###"
echo "###-----------------------###"

mkfs.fat -F32 /dev/"$disk"1 # EFI
mkswap /dev/"$disk"2 # SWAP 
mkfs.ext4 /dev/"$disk"3 # /
mkfs.ext4 /dev/"$disk"4 # /home
###-------------------------------

clear
echo "###---------------------###"
echo "### Mounting partitions ###"
echo "###---------------------###"

mount /dev/"$disk"3 /mnt
mount --mkdir /dev/"$disk"1 /mnt/boot
mount --mkdir /dev/"$disk"4 /mnt/home
swapon /dev/"$disk"2 
###-----------------------------------

clear
echo "###--------------------------###"
echo "### Installing base packages ###"
echo "###--------------------------###"

pacstrap -K /mnt base linux linux-firmware base-devel git intel-ucode linux-headers reflector nano openssh awk
###-----------------------------------------------------------------------------------------------------------

clear
echo "###---------------------###"
echo "### Creating file table ###"
echo "###---------------------###"

genfstab -U /mnt >> /mnt/etc/fstab
###-------------------------------

clear
echo "###--------------------------------###"
echo "### Copying scripts to base system ###"
echo "###--------------------------------###"

mkdir /mnt/archinstaller
cp configure.sh /mnt/archinstaller/
cp required-packages-packman /mnt/archinstaller/
cp required-packages-yay /mnt/archinstaller/
cp required-services /mnt/archinstaller/
###----------------------------------------------

clear
echo "###-------------------------###"
echo "### chroot into base system ###"
echo "###-------------------------###"

arch-chroot /mnt ./archinstaller/configure.sh
