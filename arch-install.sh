set -e

##################################
## Step 0 - prepare

# Resize existing Windows partition on new machine
# Download arch ISO (https://archlinux.org/download/)
# Burn it on a USB key (dd bs=4M if=path/to/archlinux.iso of=/dev/sdx status=progress oflag=sync)
# Boot from the key
# Setup wifi (iwctl, device list, station wlan0 scan, station wlan0 get-networks, station wlan0 connect $network)
# Set root password on USB install arch (passwd)
# Start sshd (systemctl start sshd)
# Get machine IP (ip a) and SSH to it

##################################
## Step 1 - disk
# Check all partitions (lsblk), we assume an existing Windows EFI partition, if not check how to create one
# nvme0n1     259:0    0 476.9G  0 disk 
# ├─nvme0n1p1 259:1    0   260M  0 part 
# ├─nvme0n1p2 259:2    0    16M  0 part 
# ├─nvme0n1p3 259:3    0 195.8G  0 part 
# ├─nvme0n1p4 259:4    0  1000M  0 part 
# └─nvme0n1p5 259:5    0 279.9G  0 part 

# Run cgdisk (cgdisk /dev/nvme0n1)
#  1. Create new boot partition of 512Mib (start at default, default hex code/guid)
#  2. Create root partition with remainder (all default values)
#  3. Write

# Download this script to run it
# wget https://raw.githubusercontent.com/matthieu/config/master/install.sh

# WARNING: before running those, make sure the disk names match
cryptsetup -y --use-random luksFormat /dev/nvme0n1p6
cryptsetup luksOpen /dev/nvme0n1p6 cryptroot
# format boot and encrypted partitions
mkfs.ext4 /dev/nvme0n1p5
mkfs.ext4 /dev/mapper/cryptroot
# Prepare filesystem
mount /dev/mapper/cryptroot /mnt
mkdir -p /mnt/boot/efi
mount /dev/nvme0n1p5 /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot/efi
pacstrap /mnt linux linux-firmware base base-devel grub efibootmgr vim git intel-ucode networkmanager
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt

##################################
## Step 2 - configure

sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
export LANG=en_US.UTF-8

ln -s /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
hwclock --systohc --utc
echo carby > /etc/hostname

pacman -S sudo grub-bios os-prober

passwd
useradd -m -G wheel mriou
passwd mriou
visudo
# Uncomment %wheel ALL=(ALL) NOPASSWD: ALL
systemctl enable NetworkManager

echo "The rest requires some manual editing, check step 3"

##################################
## Step 3 - kernel and grub

# Check the UUID of the root and EFI partitions (blkid)
# Edit grub config (vim /etc/default/grub) to the following, replacing UUIDs
#   GRUB_CMDLINE_LINUX="cryptdevice=UUID=fce2894e-05bd-40ec-8fa5-3fb6a069b283:cryptroot root=/dev/mapper/cryptroot"

# vim /etc/mkinitcpio.conf and change HOOKS definition to be like this:
#   HOOKS=(base udev autodetect keyboard modconf block encrypt filesystems fsck)
# mkinitcpio -p linux

# Setup grub
#   grub-install --recheck /dev/sda
#   grub-mkconfig --output /boot/grub/grub.cfg

##################################
## Step 4 - finishing up

# Enable networking for next reboot
#   systemctl enable NetworkManager
# exit, umount -R /mnt, reboot

# Login, connect to wifi (nmtui-connect) and install gnome as well as some other applications
#   sudo pacman -Sy gnome tmux alacritty firefox gimp vlc wget
#   sudo systemctl enable gdm

