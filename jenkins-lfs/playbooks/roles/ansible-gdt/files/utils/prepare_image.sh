#!/bin/bash
# setup-lfs-image.sh
# Builds a bootable qcow2 image from an existing LFS rootfs using mkosi,
# then creates and starts the VM (+ Alpine debug VM) via libvirt.
#
# Usage: sudo ./setup-lfs-image.sh
set -euo pipefail

# ── Config ───────────────────────────────────────────────────────────────────
LFS_KERNEL_VERSION="6.13.4"
LFS_WORKDIR="/mnt/lfs"
NET_DEV="ens3"
GDT_HOSTNAME="devopstribe-linux-amd64"

IMAGE_PATH="/var/lib/libvirt/images/lfs.qcow2"
IMAGE_CLONE_PATH="/var/lib/libvirt/images/lfs-clone.qcow2"
LIVE_VM_ISO_PATH="/var/lib/libvirt/images/alpine.iso"

VM_NAME="lfs-vm"
LIVE_VM_NAME="lfs-vm-live-debug"
VIRSH_NETWORK="default"

MKOSI_WORKDIR="/tmp/mkosi-lfs-build"

# ── Checks ───────────────────────────────────────────────────────────────────
echo "[INFO] Checking dependencies..."
for cmd in mkosi virsh virt-install qemu-img; do
  command -v "$cmd" &>/dev/null || { echo "[ERROR] '$cmd' not found. Please install it."; exit 1; }
done

[ -d "$LFS_WORKDIR" ] || { echo "[ERROR] LFS not found at $LFS_WORKDIR"; exit 1; }
[ -f "$LIVE_VM_ISO_PATH" ] || { echo "[ERROR] Please put alpine.iso in $LIVE_VM_ISO_PATH"; exit 1; }

# ── Umount LFS virtual filesystems se montati ─────────────────────────────────
echo "[INFO] Unmounting LFS virtual filesystems if mounted..."
for mnt in /mnt/lfs/dev/pts /mnt/lfs/dev /mnt/lfs/proc /mnt/lfs/sys; do
  mountpoint -q "$mnt" && sudo umount "$mnt" && echo "[INFO] Unmounted $mnt" || true
done

# ── Cleanup VM esistenti ──────────────────────────────────────────────────────
echo "[INFO] Cleaning up existing VMs..."
for vm in "$VM_NAME" "$LIVE_VM_NAME"; do
  if virsh list --all | grep -q "$vm"; then
    echo "[INFO] Removing VM $vm..."
    sudo virsh destroy "$vm" 2>/dev/null || true
    sudo virsh undefine "$vm" 2>/dev/null || true
  fi
done

# ── Prepara workdir mkosi ─────────────────────────────────────────────────────
echo "[INFO] Preparing mkosi working directory at $MKOSI_WORKDIR..."
sudo rm -rf "$MKOSI_WORKDIR"
sudo mkdir -p "$MKOSI_WORKDIR/output"

# ── Scrivi mkosi.conf ─────────────────────────────────────────────────────────
echo "[INFO] Writing mkosi.conf..."
sudo tee "$MKOSI_WORKDIR/mkosi.conf" > /dev/null << EOF
[Distribution]
Distribution=custom

[Output]
Format=disk
ImageId=lfs-vm
OutputDirectory=output
CompressOutput=no

[Host]
QemuFirmware=bios

[Content]
# Con Distribution=custom il rootfs va fornito via BaseTrees=
# (RootDirectory= è stato rimosso in mkosi v20)
BaseTrees=$MKOSI_WORKDIR/lfs-rootfs.tar
Packages=

PostInstallationScripts=mkosi.postinst

[Bootloader]
Bootloader=grub
UnifiedKernelImages=no
BiosBootPartition=yes
KernelCommandLine=root=/dev/vda2 ro nomodeset debug earlyprintk=efi,keep console=ttyS0,115200 console=tty1
EOF

# ── Scrivi mkosi.postinst ─────────────────────────────────────────────────────
echo "[INFO] Writing mkosi.postinst..."
sudo tee "$MKOSI_WORKDIR/mkosi.postinst" > /dev/null << POSTINST
#!/bin/bash
# Runs inside a chroot of the final LFS image
set -euo pipefail

echo "[postinst] Setting root password..."
# TODO: replace with hashed secret or external vault
echo "root:luckysideburn.123" | chpasswd

echo "[postinst] Setting hostname..."
echo "$GDT_HOSTNAME" > /etc/hostname

echo "[postinst] Writing /etc/fstab..."
cat > /etc/fstab << EOF
# file system  mount-point    type     options             dump  fsck
/dev/vda1      /boot          ext4     defaults            1     1
/dev/vda2      /              ext4     defaults            1     1
proc           /proc          proc     nosuid,noexec,nodev 0     0
sysfs          /sys           sysfs    nosuid,noexec,nodev 0     0
devpts         /dev/pts       devpts   gid=5,mode=620      0     0
tmpfs          /run           tmpfs    defaults            0     0
devtmpfs       /dev           devtmpfs mode=0755,nosuid    0     0
tmpfs          /dev/shm       tmpfs    nosuid,nodev        0     0
cgroup2        /sys/fs/cgroup cgroup2  nosuid,noexec,nodev 0     0
EOF

echo "[postinst] Writing network config..."
mkdir -p /etc/sysconfig
cat > /etc/sysconfig/ifconfig.${NET_DEV} << EOF
ONBOOT=no
IFACE=${NET_DEV}
SERVICE=ipv4-static
IP=192.168.122.100
GATEWAY=192.168.122.1
PREFIX=24
BROADCAST=192.168.122.255
EOF

echo "[postinst] Writing /etc/resolv.conf..."
cat > /etc/resolv.conf << EOF
domain 0xHrtx.local
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF

echo "[postinst] Writing /etc/sysconfig/clock..."
cat > /etc/sysconfig/clock << EOF
UTC=1
CLOCKPARAMS=
EOF

echo "[postinst] Writing /etc/inittab..."
cat > /etc/inittab << EOF
id:3:initdefault:
si::sysinit:/etc/rc.d/init.d/rc S
l0:0:wait:/etc/rc.d/init.d/rc 0
l1:S1:wait:/etc/rc.d/init.d/rc 1
l2:2:wait:/etc/rc.d/init.d/rc 2
l3:3:wait:/etc/rc.d/init.d/rc 3
l4:4:wait:/etc/rc.d/init.d/rc 4
l5:5:wait:/etc/rc.d/init.d/rc 5
l6:6:wait:/etc/rc.d/init.d/rc 6
ca:12345:ctrlaltdel:/sbin/shutdown -t1 -a -r now
su:S06:once:/sbin/sulogin
s1:1:respawn:/sbin/sulogin
1:2345:respawn:/sbin/agetty --noclear tty1 9600
2:2345:respawn:/sbin/agetty tty2 9600
3:2345:respawn:/sbin/agetty tty3 9600
4:2345:respawn:/sbin/agetty tty4 9600
5:2345:respawn:/sbin/agetty tty5 9600
6:2345:respawn:/sbin/agetty tty6 9600
EOF

echo "[postinst] Building initramfs with dracut (inside chroot)..."
dracut --force \\
    --kver "${LFS_KERNEL_VERSION}" \\
    --add "bash kernel-modules rootfs-block base" \\
    --omit "systemd" \\
    --filesystems "ext4" \\
    --drivers "virtio_blk virtio_pci" \\
    /boot/initrd-${LFS_KERNEL_VERSION}

echo "[postinst] Done."
POSTINST

sudo chmod +x "$MKOSI_WORKDIR/mkosi.postinst"

# ── Crea tar della LFS con esclusioni ────────────────────────────────────────
LFS_TAR="$MKOSI_WORKDIR/lfs-rootfs.tar"
echo "[INFO] Creating tar of LFS rootfs (excluding unnecessary directories)..."
sudo tar -C "$LFS_WORKDIR" \
  --exclude='./root/.cache' \
  --exclude='./root/go' \
  --exclude='./tools' \
  --exclude='./sources' \
  --exclude='./tmp' \
  --exclude='./var/cache' \
  --exclude='./var/log' \
  -cf "$LFS_TAR" .
echo "[INFO] LFS tar created at $LFS_TAR"

# ── Build immagine con mkosi ──────────────────────────────────────────────────
echo "[INFO] Building image with mkosi (this may take a while)..."
cd "$MKOSI_WORKDIR"
sudo mkosi build

BUILT_IMAGE="$MKOSI_WORKDIR/output/lfs-vm.raw"
[ -f "$BUILT_IMAGE" ] || { echo "[ERROR] mkosi did not produce $BUILT_IMAGE"; exit 1; }
echo "[INFO] Image built successfully: $BUILT_IMAGE"

# ── Converti raw → qcow2 e copia in libvirt ───────────────────────────────────
echo "[INFO] Converting raw image to qcow2..."
[ -f "$IMAGE_PATH" ] && sudo rm -f "$IMAGE_PATH"
sudo qemu-img convert -f raw -O qcow2 "$BUILT_IMAGE" "$IMAGE_PATH"
echo "[INFO] Image converted and saved to $IMAGE_PATH"

echo "[INFO] Cloning image to $IMAGE_CLONE_PATH..."
[ -f "$IMAGE_CLONE_PATH" ] && sudo rm -f "$IMAGE_CLONE_PATH"
sudo qemu-img create -f qcow2 -b "$IMAGE_PATH" -F qcow2 "$IMAGE_CLONE_PATH"
echo "[INFO] Clone created (copy-on-write, based on original)."

# ── Crea VM principale ────────────────────────────────────────────────────────
echo "[INFO] Creating VM $VM_NAME..."
sudo -i -u ubuntu virt-install \
  --name "$VM_NAME" \
  --memory 2048 \
  --disk path="$IMAGE_PATH",format=qcow2,bus=virtio \
  --os-variant generic \
  --network network="$VIRSH_NETWORK",model=virtio \
  --graphics vnc,listen=0.0.0.0 \
  --video virtio \
  --import \
  --noautoconsole

echo "[INFO] VM $VM_NAME created successfully."

# ── Crea VM di debug con Alpine ISO ──────────────────────────────────────────
echo "[INFO] Creating debug VM $LIVE_VM_NAME (Alpine ISO + LFS clone)..."
sudo -i -u ubuntu virt-install \
  --name "$LIVE_VM_NAME" \
  --memory 512 \
  --disk path="$LIVE_VM_ISO_PATH",format=raw,bus=ide,device=cdrom \
  --disk path="$IMAGE_CLONE_PATH",format=qcow2,bus=virtio \
  --os-variant generic \
  --network network="$VIRSH_NETWORK",model=virtio \
  --graphics vnc,listen=0.0.0.0 \
  --import \
  --noautoconsole

echo "[INFO] Debug VM $LIVE_VM_NAME created successfully."

# ── Riepilogo ─────────────────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[DONE] All steps completed successfully."
echo "  Main image : $IMAGE_PATH"
echo "  Clone      : $IMAGE_CLONE_PATH (CoW, debug)"
echo "  VM         : $VM_NAME"
echo "  Debug VM   : $LIVE_VM_NAME (boots Alpine ISO)"
echo ""
echo "  Connect via VNC or: sudo virsh console $VM_NAME"
echo "  Debug shell: cd $MKOSI_WORKDIR && sudo mkosi shell"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"