# Arch Linux Setup SCripts
A collection of scripts to automate the setup and configuration of Arch Linux

## Create and format partitions
  This is where we get a list of disks available on the system and allow the user to select 1.
  Once a disk has been selected the script will then create 4 partions on that disk.
    p1: 550MB EFI parttition [/boot] [FAT32]
    p2: 2GB SWAP partition [SWAP] 
    p3: 20GB Root Partition [/] [EXT4]
    p4: Home partition [/home] [EXT4]

  It will create and size each partition and change the partition type before then formatting each as required.
  

