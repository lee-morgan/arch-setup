#!/bin/bash
# This is just an testbed script used to test various sections of code

#pacman -Qet > packages.txt
# Sort installed packages into the correct package manager / helper files
comm -12 <(pacman -Slq | sort) <(sort packages.txt) > pacman-packages.txt
comm -23 <(sort packages.txt) <(pacman -Slq | sort) > aur-packages.txt
#sudo pacman --noconfirm --needed --noprogressbar -S $(awk '{print $1}' ./pacman-packages.txt)
#yay --noconfirm --needed --noprogressbar -S $(awk '{print $1}' ./aur-packages.txt)

# yay_packages=()
# pacman_packages=()
# missing_packages=()

# RED='\033[0;31m'
# RESET='\033[0m'

# readarray -t packages < packages.txt

# for package in "${packages[@]}"; do
#   if (pacman -Ssq "^${package}$" > /dev/null); then
#     echo -e "\e[1A\e[K$package found in the arch repository"
#     pacman_packages+=("$package")
#   else 
#     if (yay -Ssq ${package} | grep -i ${package} > /dev/null); then
#       echo -e "\e[1A\e[K$package found in the user repository"
#       yay_packages+=("$package")
#     else 
#       echo -e "${RED}$package not found in any repository${RESET}"
#       missing_packages+=("$package")
#     fi
#   fi
# done

# if [ ${#pacman_packages[@]} -gt 0 ]; then
#     echo "${pacman_packages[@]}" > pacman-packages.txt
# fi

# if [ ${#yay_packages[@]} -gt 0 ]; then
#     echo "${yay_packages[@]}" > yay-packages.txt
# fi

# if [ ${#missing_packages[@]} -gt 0 ]; then
#     echo "${missing_packages[@]}" > missing-packages.txt
# fi
