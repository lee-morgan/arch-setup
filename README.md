# Arch Linux Setup Scripts
  A collection of scripts to automate the setup and configuration of Arch Linux

## Create and format partitions
This is where we get a list of disks available on the system and allow the user to select 1.  
Once a disk has been selected the script will then create 4 partitions on that disk.  
+ :cd:#1 550MB EFI parttition [/boot] [FAT32]  
+ :cd:#2 2GB SWAP partition [SWAP]   
+ :cd:#3 20GB Root Partition [/] [EXT4]  
+ :cd:#4 Home partition [/home] [EXT4]  

It will create and size each partition and change the partition type before then formatting each as required.
  

