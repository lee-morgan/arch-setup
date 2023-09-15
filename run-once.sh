#!/bin/bash 

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m' 
CYAN='\033[0;36m' 
RESET='\033[0m'

timeout=2

clear
echo -e "${CYAN}"
echo "###---------------------------------------------###"
echo "###                                             ###"
echo "###             Enable user services            ###"
echo "###                                             ###"
echo "###---------------------------------------------###"
echo -e "${RESET}"

# systemctl --user enable --now pipewire  
# systemctl --user enable --now pipewire-pulse 
# systemctl --user enable --now pipewire-media-session

clear
echo -e "${CYAN}"
echo "###---------------------------------------------###"
echo "###                                             ###"
echo "###            Cleanup setup scripts            ###"
echo "###                                             ###"
echo "###---------------------------------------------###"
echo -e "${RESET}"

echo "$0"

###---------------------------------------------------------