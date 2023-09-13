#!/bin/bash

### Continue the installation
ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime
hwclock –systohc
sed -i 's/#en_gb.UTF/en_GB.UTF/' /etc/loacale.gen
locale-gen
echo "LANG=en_GB.UTF-8" >> /etc/locale.conf
echo "KEYMAP=uk"  >> /etc/vconsole.conf

### Set the hostname
read -p 'Please enter a hostname for this device: ' hostname
echo $hostname >> /etc/hostname

### Create the hosts file
echo -e "127.0.0.1\tlocalhost" >> /etc/hosts
echo -e "::1\t\tlocalhost" >> /etc/hosts
echo -e "127.0.1.1\t$hostname.local\t$hostname" >> /etc/hosts
