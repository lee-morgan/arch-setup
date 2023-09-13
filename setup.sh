#!/bin/bash

# Setup Partitions
(echo g; echo n; echo 1; echo ; echo ; echo +550M; 
echo n; echo 2; echo ; echo ; echo +2G; 
echo n; echo 3; echo ; echo ; echo +20G; 
echo n; echo 4; echo ; echo ; echo ; 
echo t; echo 1; echo 1; echo ;  
echo t; echo 2; echo 19; echo ; 
echo w) | fdisk /dev/vda
