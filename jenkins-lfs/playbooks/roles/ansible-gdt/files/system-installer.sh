#!/bin/bash
# LFS Live System Installer
# A dialog-based installer for LFS

DIALOG=${DIALOG=dialog}
TEMP_FILE=$(mktemp)
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export PATH
trap "rm -f $TEMP_FILE" 0 1 2 5 15

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "This installer must be run as root"
    exit 1
fi

# Welcome screen
$DIALOG --title "LFS System Installer" \
    --msgbox "Welcome to the DevOpsTribe GNU/Linux Installer!\n\nThis will install the operating system to your hard drive.\n\nPress OK to continue." 10 50

# Detect available disks
DISKS=$(lsblk -dpno NAME,SIZE,TYPE | grep disk | awk '{print $1 " \"" $2 "\""}')

if [ -z "$DISKS" ]; then
    $DIALOG --title "Error" --msgbox "No disks found!" 6 40
    exit 1
fi

# Select target disk
$DIALOG --title "Select Installation Disk" \
    --menu "Choose the disk to install LFS:" 15 60 5 \
    $(echo "$DISKS") 2>$TEMP_FILE

TARGET_DISK=$(cat $TEMP_FILE)

if [ -z "$TARGET_DISK" ]; then
    exit 0
fi

# Warning
$DIALOG --title "WARNING" \
    --yesno "All data on $TARGET_DISK will be DESTROYED!\n\nAre you sure you want to continue?" 8 50

if [ $? -ne 0 ]; then
    exit 0
fi

# Partition scheme
$DIALOG --title "Partition Scheme" \
    --menu "Select partitioning scheme:" 12 60 3 \
    1 "Automatic (Recommended)" \
    2 "Manual (Advanced)" \
    3 "Use existing partitions" 2>$TEMP_FILE

PART_SCHEME=$(cat $TEMP_FILE)

# Hostname
$DIALOG --title "System Configuration" \
    --inputbox "Enter hostname for your system:" 8 50 "lfs-system" 2>$TEMP_FILE

HOSTNAME=$(cat $TEMP_FILE)

# Root password
$DIALOG --title "Root Password" \
    --passwordbox "Enter root password:" 8 50 2>$TEMP_FILE

ROOT_PASS=$(cat $TEMP_FILE)

$DIALOG --title "Root Password" \
    --passwordbox "Confirm root password:" 8 50 2>$TEMP_FILE

ROOT_PASS2=$(cat $TEMP_FILE)

if [ "$ROOT_PASS" != "$ROOT_PASS2" ]; then
    $DIALOG --title "Error" --msgbox "Passwords do not match!" 6 40
    exit 1
fi

# Create user
$DIALOG --title "User Account" \
    --yesno "Create a regular user account?" 6 40

if [ $? -eq 0 ]; then
    $DIALOG --title "User Account" \
        --inputbox "Enter username:" 8 50 2>$TEMP_FILE
    USERNAME=$(cat $TEMP_FILE)
    
    $DIALOG --title "User Password" \
        --passwordbox "Enter password for $USERNAME:" 8 50 2>$TEMP_FILE
    USER_PASS=$(cat $TEMP_FILE)
fi

# Confirm installation
$DIALOG --title "Confirm Installation" \
    --yesno "Ready to install LFS with the following settings:\n\n\
Target Disk: $TARGET_DISK\n\
Hostname: $HOSTNAME\n\
Username: ${USERNAME:-none}\n\n\
Proceed with installation?" 14 60

if [ $? -ne 0 ]; then
    exit 0
fi

# Installation progress
(
echo "10" ; echo "# Partitioning disk..."
sleep 1

if [ "$PART_SCHEME" = "1" ]; then
    # Automatic partitioning
    parted -s $TARGET_DISK mklabel gpt
    parted -s $TARGET_DISK mkpart primary fat32 1MiB 512MiB
    parted -s $TARGET_DISK set 1 esp on
    parted -s $TARGET_DISK mkpart primary ext4 512MiB 100%
    
    # Format partitions
    mkfs.fat -F32 ${TARGET_DISK}1
    mkfs.ext4 -F ${TARGET_DISK}2
    
    BOOT_PART="${TARGET_DISK}1"
    ROOT_PART="${TARGET_DISK}2"
fi

echo "30" ; echo "# Mounting filesystems..."
sleep 1

mkdir -p /mnt/install
mount $ROOT_PART /mnt/install
mkdir -p /mnt/install/boot/efi
mount $BOOT_PART /mnt/install/boot/efi

echo "40" ; echo "# Copying system files..."
sleep 1

# Copy everything except live-only directories
rsync -a --info=progress2 \
    --exclude=/proc --exclude=/sys --exclude=/dev \
    --exclude=/run --exclude=/tmp --exclude=/mnt \
    --exclude=/media --exclude=/lost+found \
    / /mnt/install/

echo "70" ; echo "# Configuring system..."
sleep 1

# Set hostname
echo "$HOSTNAME" > /mnt/install/etc/hostname

# Update fstab
BOOT_UUID=$(blkid -s UUID -o value $BOOT_PART)
ROOT_UUID=$(blkid -s UUID -o value $ROOT_PART)

cat > /mnt/install/etc/fstab << EOF
# /etc/fstab
UUID=$ROOT_UUID    /           ext4    defaults        0 1
UUID=$BOOT_UUID    /boot/efi   vfat    defaults        0 2
proc               /proc       proc    nosuid,noexec,nodev 0 0
sysfs              /sys        sysfs   nosuid,noexec,nodev 0 0
devpts             /dev/pts    devpts  gid=5,mode=620  0 0
tmpfs              /run        tmpfs   defaults        0 0
devtmpfs           /dev        devtmpfs mode=0755,nosuid 0 0
tmpfs              /tmp        tmpfs   defaults        0 0
EOF

echo "80" ; echo "# Setting up users..."
sleep 1

# Set root password
echo "root:$ROOT_PASS" | chroot /mnt/install chpasswd

# Create user if specified
if [ -n "$USERNAME" ]; then
    chroot /mnt/install useradd -m -G wheel,audio,video -s /bin/bash $USERNAME
    echo "$USERNAME:$USER_PASS" | chroot /mnt/install chpasswd
fi

echo "90" ; echo "# Installing bootloader..."
sleep 1

# Install GRUB
chroot /mnt/install grub-install --target=x86_64-efi \
    --efi-directory=/boot/efi --bootloader-id=LFS

# Generate GRUB config
chroot /mnt/install grub-mkconfig -o /boot/grub/grub.cfg

echo "100" ; echo "# Installation complete!"
sleep 2

) | $DIALOG --title "Installing LFS" --gauge "Preparing..." 10 70 0

# Success message
$DIALOG --title "Installation Complete" \
    --msgbox "LFS has been successfully installed!\n\n\
The system will now reboot.\n\n\
Remove the installation media before reboot." 10 50

# Cleanup
umount /mnt/install/boot/efi
umount /mnt/install

# Reboot
reboot