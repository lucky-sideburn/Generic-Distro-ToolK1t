#!/bin/bash
#!/bin/bash
# Script to prepare a bootable LFS Live ISO
# Assumes LFS is mounted at /mnt/lfs

set -euo pipefail

ISO_WORKSPACE="/tmp/lfs_iso_ws"
LFS_KERNEL_VERSION="6.13.4"
LFS_ROOT="/mnt/lfs"
LFS_HOSTNAME="devopstribe-linux"
ISO_OUTPUT="/var/lib/libvirt/images/lfs-system.iso"
ISO_LABEL="${LFS_HOSTNAME}_ISO"

find_kernel_image() {
  find "$LFS_ROOT/boot" -maxdepth 1 -type f -name "vmlinuz-${LFS_KERNEL_VERSION}*" | head -n 1
}

KERNEL_IMAGE="$(find_kernel_image)"

if [ -z "$KERNEL_IMAGE" ]; then
  echo "Error: could not find a kernel image for version ${LFS_KERNEL_VERSION} under ${LFS_ROOT}/boot"
  exit 1
fi

sudo mkdir -p "$ISO_WORKSPACE"
sudo rm -f "$ISO_OUTPUT"

sudo rsync -avz --delete --progress \
  --exclude='/root/.cache' \
  --exclude='/root/go' \
  --exclude='/sources' \
  --exclude='/tmp' \
  --exclude='/build' \
  --exclude='/proc/*' \
  --exclude='/sys/*' \
  --exclude='/dev/*' \
  --exclude='/run/*' \
  --exclude='/var/cache/*' \
  --exclude='/var/log/*' \
  --exclude='/tools' \
  "$LFS_ROOT/" "$ISO_WORKSPACE/"

sudo mkdir -p "$ISO_WORKSPACE/live" "$ISO_WORKSPACE/boot/grub"
sudo cp "$KERNEL_IMAGE" "$ISO_WORKSPACE/live/vmlinuz"

sudo dracut --force \
  --kver "$LFS_KERNEL_VERSION" \
  --kmoddir "$LFS_ROOT/lib/modules/$LFS_KERNEL_VERSION" \
  --add "dmsquash-live bash kernel-modules rootfs-block base loop" \
  --omit "systemd multipath btrfs" \
  --filesystems "iso9660 squashfs overlay" \
  --drivers "virtio_pci virtio_blk virtio_scsi sr_mod cdrom sd_mod loop" \
  --no-hostonly \
  "$ISO_WORKSPACE/live/initrd"

sudo tee "$ISO_WORKSPACE/boot/grub/grub.cfg" > /dev/null << EOF
insmod part_gpt
insmod part_msdos
insmod iso9660
insmod all_video

set default=0
set timeout=5

search --no-floppy --set=root --label ${ISO_LABEL}

menuentry "$LFS_HOSTNAME GNU/Linux Live" {
    set gfxpayload=keep
    linux /live/vmlinuz root=live:CDLABEL=${ISO_LABEL} rd.live.image rd.live.dir=/live rd.live.overlay.overlayfs=1 console=tty1 console=ttyS0
    initrd /live/initrd
}
EOF

sudo tee "$ISO_WORKSPACE/etc/inittab" > /dev/null << 'EOF'
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
1:2345:respawn:/sbin/agetty tty1 9600
2:2345:respawn:/sbin/agetty tty2 9600
3:2345:respawn:/sbin/agetty tty3 9600
EOF

sudo tee "$ISO_WORKSPACE/etc/fstab" > /dev/null << 'EOF'
# file system  mount-point    type     options             dump  fsck
proc           /proc          proc     nosuid,noexec,nodev 0     0
sysfs          /sys           sysfs    nosuid,noexec,nodev 0     0
devpts         /dev/pts       devpts   gid=5,mode=620      0     0
tmpfs          /run           tmpfs    defaults            0     0
devtmpfs       /dev           devtmpfs mode=0755,nosuid    0     0
tmpfs          /dev/shm       tmpfs    nosuid,nodev        0     0
cgroup2        /sys/fs/cgroup cgroup2  nosuid,noexec,nodev 0     0
EOF

sudo rm -f "$ISO_WORKSPACE/etc/rc.d/rcS.d/S45cleanfs"
sudo rm -f "$ISO_WORKSPACE/etc/rc.d/rcS.d/S40mountfs"
sudo rm -f "$ISO_WORKSPACE/etc/rc.d/rc3.d/S92kubelet"
sudo rm -f "$ISO_WORKSPACE/etc/rc.d/rc3.d/S30sshd"
sudo rm -f "$ISO_WORKSPACE/etc/rc.d/rcS.d/S30checkfs"

echo "$LFS_HOSTNAME" | sudo tee "$ISO_WORKSPACE/etc/hostname" > /dev/null

sudo tee "$ISO_WORKSPACE/etc/hosts" > /dev/null << 'EOF'
# Begin /etc/hosts

127.0.0.1 localhost.localdomain localhost
127.0.1.1 lfs-live.localdomain lfs-live
::1       localhost ip6-localhost ip6-loopback
ff02::1   ip6-allnodes
ff02::2   ip6-allrouters

# End /etc/hosts
EOF

sudo tee "$ISO_WORKSPACE/etc/rc.d/init.d/hostname" > /dev/null << 'EOF'
#!/bin/sh

. /lib/lsb/init-functions

case "$1" in
   start)
      log_info_msg "Setting hostname..."
      hostname -F /etc/hostname
      evaluate_retval
      ;;
   *)
      echo "Usage: $0 {start}"
      exit 1
      ;;
esac
EOF

sudo tee "$ISO_WORKSPACE/root/.bashrc" > /dev/null << 'EOF'
# Custom LFS Live ISO Bashrc
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
export PS1="\[\e[1;32m\]\u@\h:\[\e[1;34m\]\w\[\e[0m\]\$ "
EOF

sudo tee "$ISO_WORKSPACE/root/.bash_profile" > /dev/null << 'EOF'
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi
EOF

sudo chmod +x "$ISO_WORKSPACE/etc/rc.d/init.d/hostname"
sudo ln -sf ../init.d/hostname "$ISO_WORKSPACE/etc/rc.d/rcS.d/S02hostname"

sudo mksquashfs "$LFS_ROOT/" "$ISO_WORKSPACE/live/filesystem.squashfs" \
  -e boot \
  -e sources \
  -e dev/* \
  -e proc/* \
  -e sys/* \
  -e run/* \
  -e tmp/* \
  -e root/.cache \
  -e root/go \
  -e var/cache \
  -e var/log \
  -e var/tmp \
  -comp xz

sudo rm -f "$ISO_WORKSPACE/initrd.img-no-kmods"
sudo rm -rf "$ISO_WORKSPACE/dist" "$ISO_WORKSPACE/tools"

sudo chmod +x "$ISO_WORKSPACE/etc/rc.d/init.d/llama-server"
sudo ln -sf ../init.d/llama-server "$ISO_WORKSPACE/etc/rc.d/rc3.d/S99llama-server"
sudo mkdir -p "$ISO_WORKSPACE/tmp" "$ISO_WORKSPACE/var/log" "$ISO_WORKSPACE/run"
sudo chmod 1777 "$ISO_WORKSPACE/tmp"

sudo grub-mkrescue --iso-level 3 \
  -o "$ISO_OUTPUT" "$ISO_WORKSPACE" -- -volid "$ISO_LABEL" \
  -publisher "${LFS_HOSTNAME}_LINUX" \
  -hfsplus off

sudo chown libvirt-qemu:kvm "$ISO_OUTPUT"

