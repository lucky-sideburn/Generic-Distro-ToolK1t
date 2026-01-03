# 1. Create workspace
ISO_WORKSPACE="/tmp/lfs_iso_ws"
sudo mkdir -p $ISO_WORKSPACE

# 2. Copy EVERYTHING from your LFS root (except /proc, /sys, /dev)
# Use -a to preserve permissions/symlinks which are critical for LFS
sudo rsync -a --progress --exclude='sources' /mnt/lfs/ $ISO_WORKSPACE/

# 3. Ensure the kernel is in the right place inside the workspace
sudo cp /mnt/lfs/boot/vmlinuz-6.13.4-lfs-12.3 $ISO_WORKSPACE/boot/vmlinuz

# 4. Create the GRUB config INSIDE the workspace
sudo mkdir -p $ISO_WORKSPACE/boot/grub
sudo tee $ISO_WORKSPACE/boot/grub/grub.cfg << EOF
set default=0
set timeout=10
menuentry "LFS Live ISO (Full System)" {
    linux /boot/vmlinuz root=/dev/sr0 ro rootfstype=iso9660 init=/sbin/init
    initrd /boot/initrd.img-6.13.4
}
EOF

sudo tee $ISO_WORKSPACE/etc/inittab << 'EOF'
# Default Runlevel
id:3:initdefault:

# System initialization
si::sysinit:/etc/rc.d/init.d/rc S

# What to do in single-user mode
~:S:wait:/sbin/sulogin

# What to do when CTRL-ALT-DEL is pressed
ca::ctrlaltdel:/sbin/shutdown -t1 -a -r now

# Runlevels
l0:0:wait:/etc/rc.d/init.d/rc 0
l1:1:wait:/etc/rc.d/init.d/rc 1
l2:2:wait:/etc/rc.d/init.d/rc 2
l3:3:wait:/etc/rc.d/init.d/rc 3
l4:4:wait:/etc/rc.d/init.d/rc 4
l5:5:wait:/etc/rc.d/init.d/rc 5
l6:6:wait:/etc/rc.d/init.d/rc 6

# Consoles
1:2345:respawn:/sbin/agetty --noclear tty1 9600
2:2345:respawn:/sbin/agetty tty2 9600
3:2345:respawn:/sbin/agetty tty3 9600

# End of /etc/inittab
EOF

sudo tee $ISO_WORKSPACE/etc/fstab << 'EOF'
# Begin /etc/fstab for Live ISO

# file system  mount-point    type     options             dump  fsck
proc           /proc          proc     nosuid,noexec,nodev 0     0
sysfs          /sys           sysfs    nosuid,noexec,nodev 0     0
devpts         /dev/pts       devpts   gid=5,mode=620      0     0
tmpfs          /run           tmpfs    defaults            0     0
devtmpfs       /dev           devtmpfs mode=0755,nosuid    0     0
tmpfs          /dev/shm       tmpfs    nosuid,nodev        0     0
cgroup2        /sys/fs/cgroup cgroup2  nosuid,noexec,nodev 0     0

# CD-ROM is already mounted as root, no need to mount it again
# /dev/sr0     /              iso9660  ro                  0     0

# End /etc/fstab
EOF

sudo rm $ISO_WORKSPACE/etc/rc.d/rcS.d/S45cleanfs
sudo rm $ISO_WORKSPACE/etc/rc.d/rcS.d/S40mountfs
sudo rm $ISO_WORKSPACE/etc/rc.d/rc3.d/S92kubelet  
sudo rm $ISO_WORKSPACE/etc/rc.d/rc3.d/S91crio
sudo rm $ISO_WORKSPACE/etc/rc.d/rc3.d/S30sshd
echo "devopstribe-linux" | sudo tee $ISO_WORKSPACE/etc/hostname
# Also update /etc/hosts
sudo tee $ISO_WORKSPACE/etc/hosts << 'EOF'
# Begin /etc/hosts

127.0.0.1 localhost.localdomain localhost
127.0.1.1 lfs-live.localdomain lfs-live
::1       localhost ip6-localhost ip6-loopback
ff02::1   ip6-allnodes
ff02::2   ip6-allrouters

# End /etc/hosts
EOF

# Make sure hostname is set at boot
# Check if you have a hostname init script
ls -l $ISO_WORKSPACE/etc/rc.d/init.d/hostname

# If it doesn't exist, create one
sudo tee $ISO_WORKSPACE/etc/rc.d/init.d/hostname << 'EOF'
#!/bin/sh
########################################################################
# Begin hostname
#
# Description : Set hostname
#
########################################################################

. /lib/lsb/init-functions

case "${1}" in
   start)
      log_info_msg "Setting hostname..."
      hostname -F /etc/hostname
      evaluate_retval
      ;;
   *)
      echo "Usage: ${0} {start}"
      exit 1
      ;;
esac

# End hostname
EOF

sudo chmod +x $ISO_WORKSPACE/etc/rc.d/init.d/hostname

# Link it to run early in boot
sudo ln -sf ../init.d/hostname $ISO_WORKSPACE/etc/rc.d/rcS.d/S02hostname

# 5. Generate the ISO
# WARNING: This ISO will be the size of your entire LFS install
sudo grub-mkrescue -o /var/lib/libvirt/images/lfs-system.iso $ISO_WORKSPACE -- -hfsplus off
sudo chown libvirt-qemu:kvm /var/lib/libvirt/images/lfs-system.iso
