#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m' 
CYAN='\033[0;36m' 
RESET='\033[0m'

timeout=1

loadkeys uk 
timedatectl set-ntp true

clear
echo -e "${GREEN}"
echo "###---------------------------------------------###"
echo "###                                             ###"
echo "###             Creating partitions             ###"
echo "###                                             ###"
echo "###---------------------------------------------###"
echo -e "${RESET}"

# lsblk | grep disk | awk '{print $1}'
echo -e "Available disks: $(lsblk | grep disk | awk '{print $1,($4)}' | sed -z 's/\n/, /g;s/, $/\n/')"
read -p 'Enter the disk name: ' disk

# Save the disk as we'll need it later
echo $disk > disk

(echo g
echo n; echo 1; echo ; echo '+550M'
echo n; echo 2; echo ; echo '+2G'
echo n; echo 3; echo ; echo '+20G' 
echo n; echo 4; echo ; echo 
echo t; echo 1; echo 1
echo t; echo 2; echo 19
echo w) | fdisk /dev/$disk
sleep $timeout
###---------------------------------------------------------

clear
echo -e "${YELLOW}"
echo "###---------------------------------------------###"
echo "###                                             ###"
echo "###            Formatting partitions            ###"
echo "###                                             ###"
echo "###---------------------------------------------###"
echo -e "${RESET}"

mkfs.fat -F32 /dev/"$disk"1 # EFI
mkswap /dev/"$disk"2 # [SWAP]
mkfs.ext4 /dev/"$disk"3 # / (root)
mkfs.ext4 /dev/"$disk"4 # /home
###---------------------------------------------------------

clear
echo -e "${BLUE}"
echo "###---------------------------------------------###"
echo "###                                             ###"
echo "###             Mounting partitions             ###"
echo "###                                             ###"
echo "###---------------------------------------------###"
echo -e "${RESET}"

mount /dev/"$disk"3 /mnt
mount --mkdir /dev/"$disk"1 /mnt/boot
mount --mkdir /dev/"$disk"4 /mnt/home
swapon /dev/"$disk"2 
###---------------------------------------------------------

clear
echo -e "${PURPLE}"
echo "###---------------------------------------------###"
echo "###                                             ###"
echo "###            Patching pacman.conf             ###"
echo "###                                             ###"
echo "###---------------------------------------------###"
echo -e "${RESET}"

### Not really required.
### just thought it may look nice. :-)
sed -i 's/#Color/Color/g' /etc/pacman.conf
###---------------------------------------------------------

clear
echo -e "${CYAN}"
echo "###---------------------------------------------###"
echo "###                                             ###"
echo "###           Installing base packages          ###"
echo "###                                             ###"
echo "###---------------------------------------------###"
echo -e "${RESET}"

pacstrap -K /mnt base linux linux-firmware base-devel git intel-ucode linux-headers reflector nano openssh awk
###----------------------------------------------------------

clear
echo -e "${GREEN}"
echo "###---------------------------------------------###"
echo "###                                             ###"
echo "###             Creating file table             ###"
echo "###                                             ###"
echo "###---------------------------------------------###"
echo -e "${RESET}"

genfstab -U /mnt >> /mnt/etc/fstab
###---------------------------------------------------------

clear
echo -e "${YELLOW}"
echo "###---------------------------------------------###"
echo "###                                             ###"
echo "###       Copying scripts to base system        ###"
echo "###                                             ###"
echo "###---------------------------------------------###"
echo -e "${RESET}"

mkdir /mnt/archinstaller
cp configure.sh /mnt/archinstaller/
cp packages.txt /mnt/archinstaller/
cp disk /mnt/archinstaller/
cd run-once.sh /mnt/archinstaller
###---------------------------------------------------------

clear
echo -e "${BLUE}"
echo "###---------------------------------------------###"
echo "###                                             ###"
echo "###           chroot into base system           ###"
echo "###                                             ###"
echo "###---------------------------------------------###"
echo -e "${RESET}"

arch-chroot /mnt ./archinstaller/configure.sh
sleep $timeout 
###---------------------------------------------------------