#!/bin/bash
# prepare-lfs-image.sh
# Prepares a Linux From Scratch (LFS) image for use with KVM/QEMU
# Assumes LFS is mounted at /mnt/lfs
#
# Usage: sudo ./prepare-lfs-image.sh --buildmode host_libvirt_amd64
set -euo pipefail

# ── Config ───────────────────────────────────────────────────────────────────
LFS_KERNEL_VERSION="6.13.4"
LFS_WORKDIR="/mnt/lfs"

IMAGE_SIZE="25G"
VM_NAME="lfs-vm"
LIVE_VM_NAME="lfs-vm-live-debug"
VIRSH_NETWORK="default"
CONF_TMP="/mnt/lfs/sources/conf_tmp"
LFS_ROOT="/mnt/lfs-root"
export PATH="$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/go/bin"

# ── Argomenti ─────────────────────────────────────────────────────────────────
BUILD_MODE=""
echo "[INFO] Parsing arguments..."
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --buildmode) BUILD_MODE="$2"; shift ;;
    *) echo "[ERROR] Unknown parameter: $1"; exit 1 ;;
  esac
  shift
done

if [[ "$BUILD_MODE" != "host_libvirt_amd64" && "$BUILD_MODE" != "vagrant_qemu_aarch64" ]]; then
  echo "[ERROR] Invalid buildmode: $BUILD_MODE. Allowed: host_libvirt_amd64 | vagrant_qemu_aarch64"
  exit 1
fi

echo "[INFO] Using build mode: $BUILD_MODE"

# ── Variabili per modalità ────────────────────────────────────────────────────
if [[ "$BUILD_MODE" == "host_libvirt_amd64" ]]; then
  IMAGE_PATH="/var/lib/libvirt/images/lfs.img"
  IMAGE_CLONE_PATH="/var/lib/libvirt/images/lfs-clone.img"
  LIVE_VM_ISO_PATH="/var/lib/libvirt/images/alpine.iso"
  GDT_HOSTNAME="devopstribe-linux-amd64"
  GRUB_CONSOLE="console=ttyS0,115200 console=tty1"
  GRUB_TARGET="i386-pc"
  GRUB_DISK_FSTAB="/dev/vda1      /boot              ext4     defaults            1     1"
  NET_DEV="ens3"
  INITTAB_EXTRA_LINE=""
elif [[ "$BUILD_MODE" == "vagrant_qemu_aarch64" ]]; then
  IMAGE_PATH="/mnt/os_images/lfs.img"
  IMAGE_CLONE_PATH="/mnt/os_images/lfs-clone.img"
  LIVE_VM_ISO_PATH="/mnt/os_images/alpine.iso"
  GDT_HOSTNAME="devopstribe-linux-aarch64"
  GRUB_CONSOLE="console=tty1 console=ttyAMA0"
  GRUB_TARGET="arm64-efi"
  GRUB_DISK_FSTAB="/dev/vda1      /boot             vfat     defaults            1     1"
  NET_DEV="eth0"
  INITTAB_EXTRA_LINE="AMA0:2345:respawn:/sbin/agetty ttyAMA0 9600"
fi

# ── Checks ───────────────────────────────────────────────────────────────────
echo "[INFO] Checking dependencies..."
for cmd in qemu-img parted mkfs.ext4 grub-install rsync virsh virt-install dracut; do
  command -v "$cmd" &>/dev/null || { echo "[ERROR] '$cmd' not found."; exit 1; }
done

[ -f "$LIVE_VM_ISO_PATH" ] || { echo "[ERROR] Please put alpine.iso in $LIVE_VM_ISO_PATH"; exit 1; }

# Verifica file di configurazione pre-esistenti in CONF_TMP
echo "[INFO] Checking required config files in $CONF_TMP..."
for f in profile sysctl.conf hosts environment bash_profile; do
  [ -f "$CONF_TMP/$f" ] || { echo "[ERROR] Missing required config file: $CONF_TMP/$f"; exit 1; }
done

# ── Umount LFS virtual filesystems ───────────────────────────────────────────
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

# ── Crea immagine ─────────────────────────────────────────────────────────────
echo "[INFO] Creating new image at $IMAGE_PATH ($IMAGE_SIZE)..."
[ -f "$IMAGE_PATH" ] && sudo rm -f "$IMAGE_PATH"
sudo qemu-img create -f raw "$IMAGE_PATH" "$IMAGE_SIZE"

[ -f "$IMAGE_CLONE_PATH" ] && sudo rm -f "$IMAGE_CLONE_PATH"

# ── Umount e cleanup loop device ──────────────────────────────────────────────
echo "[INFO] Cleaning up mount points..."
[ -d /mnt/lfs-boot ] && sudo rm -rf /mnt/lfs-boot/*
[ -d /mnt/lfs-root ] && sudo rm -rf /mnt/lfs-root/*

echo "[INFO] Unmounting all loop devices..."
LOOP_DEVICES=$(sudo losetup -l | awk 'NR>1 {print $1}' | grep '/dev/loop' || true)
for DEVICE in $LOOP_DEVICES; do
  sudo umount "${DEVICE}p1" 2>/dev/null || true
  sudo umount "${DEVICE}p2" 2>/dev/null || true
done
sudo losetup -D

# ── Partizionamento ───────────────────────────────────────────────────────────
echo "[INFO] Setting up loop device and partitions..."
LOOP_DEVICE=$(sudo losetup --show -fP "$IMAGE_PATH")

if [[ -z "$LOOP_DEVICE" || ! -b "$LOOP_DEVICE" ]]; then
  echo "[ERROR] Failed to attach loop device for $IMAGE_PATH"
  exit 1
fi

wait_for_partition() {
  local partition_path="$1"
  local attempts=10

  while (( attempts > 0 )); do
    if [[ -b "$partition_path" ]]; then
      return 0
    fi

    sleep 1
    ((attempts--))
  done

  echo "[ERROR] Timed out waiting for partition device $partition_path"
  exit 1
}

if [[ "$BUILD_MODE" == "host_libvirt_amd64" ]]; then
  sudo parted -s "$LOOP_DEVICE" mklabel msdos
  sudo parted -s "$LOOP_DEVICE" mkpart primary ext4 1MiB 512MiB
  sudo parted -s "$LOOP_DEVICE" set 1 boot on
  sudo parted -s "$LOOP_DEVICE" mkpart primary ext4 512MiB 100%
  sudo mkfs.ext4 "${LOOP_DEVICE}p1"
elif [[ "$BUILD_MODE" == "vagrant_qemu_aarch64" ]]; then
  sudo parted -s "$LOOP_DEVICE" mklabel gpt
  sudo parted -s "$LOOP_DEVICE" mkpart primary fat32 1MiB 512MiB
  sudo parted -s "$LOOP_DEVICE" set 1 esp on
  sudo parted -s "$LOOP_DEVICE" mkpart primary ext4 512MiB 100%
  sudo mkfs.fat -F32 "${LOOP_DEVICE}p1"
fi

sudo partprobe "$LOOP_DEVICE" || true
sudo udevadm settle || true
wait_for_partition "${LOOP_DEVICE}p1"
wait_for_partition "${LOOP_DEVICE}p2"

sudo mkfs.ext4 "${LOOP_DEVICE}p2"

# ── Mount partizioni ──────────────────────────────────────────────────────────
echo "[INFO] Mounting partitions..."
sudo mkdir -p /mnt/lfs-boot /mnt/lfs-root
sudo mount "${LOOP_DEVICE}p1" /mnt/lfs-boot
sudo mount "${LOOP_DEVICE}p2" /mnt/lfs-root

# ── Copia rootfs ──────────────────────────────────────────────────────────────
echo "[INFO] Copying LFS rootfs to image..."
sudo rsync -a --stats \
  --exclude='/root/.cache' \
  --exclude='/root/go' \
  --exclude='/tools' \
  --exclude='/sources' \
  --exclude='/tmp' \
  --exclude='/var/cache' \
  --exclude='/var/log' \
  /mnt/lfs/* /mnt/lfs-root/

sudo mkdir -p "$LFS_ROOT/boot"

# ── File di configurazione ────────────────────────────────────────────────────
echo "[INFO] Writing configuration files to $CONF_TMP..."

sudo tee "$CONF_TMP/inittab" > /dev/null << EOF
id:3:initdefault:
si::sysinit:/etc/rc.d/init.d/rc S
l0:0:wait:/etc/rc.d/init.d/rc   0
l1:S1:wait:/etc/rc.d/init.d/rc  1
l2:2:wait:/etc/rc.d/init.d/rc   2
l3:3:wait:/etc/rc.d/init.d/rc   3
l4:4:wait:/etc/rc.d/init.d/rc   4
l5:5:wait:/etc/rc.d/init.d/rc   5
l6:6:wait:/etc/rc.d/init.d/rc   6
ca:12345:ctrlaltdel:/sbin/shutdown -t1 -a -r now
su:S06:once:/sbin/sulogin
s1:1:respawn:/sbin/sulogin
1:2345:respawn:/sbin/agetty --noclear tty1 9600
2:2345:respawn:/sbin/agetty tty2 9600
3:2345:respawn:/sbin/agetty tty3 9600
4:2345:respawn:/sbin/agetty tty4 9600
5:2345:respawn:/sbin/agetty tty5 9600
6:2345:respawn:/sbin/agetty tty6 9600
${INITTAB_EXTRA_LINE}
EOF

sudo tee "$CONF_TMP/ifconfig.${NET_DEV}" > /dev/null << EOF
ONBOOT=no
IFACE=${NET_DEV}
SERVICE=ipv4-static
IP=192.168.122.100
GATEWAY=192.168.122.1
PREFIX=24
BROADCAST=192.168.122.255
EOF

sudo tee "$CONF_TMP/resolv.conf" > /dev/null << "EOF"
domain 0xHrtx.local
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF

sudo tee "$CONF_TMP/clock" > /dev/null << "EOF"
UTC=1
CLOCKPARAMS=
EOF

sudo tee "$CONF_TMP/fstab" > /dev/null << EOF
${GRUB_DISK_FSTAB}
/dev/vda2      /              ext4     defaults            1     1
proc           /proc          proc     nosuid,noexec,nodev 0     0
sysfs          /sys           sysfs    nosuid,noexec,nodev 0     0
devpts         /dev/pts       devpts   gid=5,mode=620      0     0
tmpfs          /run           tmpfs    defaults            0     0
devtmpfs       /dev           devtmpfs mode=0755,nosuid    0     0
tmpfs          /dev/shm       tmpfs    nosuid,nodev        0     0
cgroup2        /sys/fs/cgroup cgroup2  nosuid,noexec,nodev 0     0
EOF

sudo tee "$CONF_TMP/hostname" > /dev/null << EOF
${GDT_HOSTNAME}
EOF

echo "[INFO] Copying config files to $LFS_ROOT..."
sudo /bin/cp "$CONF_TMP/inittab"              "$LFS_ROOT/etc/inittab"
sudo /bin/cp "$CONF_TMP/resolv.conf"          "$LFS_ROOT/etc/resolv.conf"
sudo /bin/cp "$CONF_TMP/clock"                "$LFS_ROOT/etc/sysconfig/clock"
sudo /bin/cp "$CONF_TMP/fstab"                "$LFS_ROOT/etc/fstab"
sudo /bin/cp "$CONF_TMP/ifconfig.$NET_DEV"    "$LFS_ROOT/etc/sysconfig/ifconfig.$NET_DEV"
sudo /bin/cp "$CONF_TMP/hostname"             "$LFS_ROOT/etc/hostname"
sudo /bin/cp "$CONF_TMP/profile"              "$LFS_ROOT/etc/profile"
sudo /bin/cp "$CONF_TMP/sysctl.conf"          "$LFS_ROOT/etc/sysctl.conf"
sudo /bin/cp "$CONF_TMP/hosts"                "$LFS_ROOT/etc/hosts"
sudo /bin/cp "$CONF_TMP/environment"          "$LFS_ROOT/etc/environment"
sudo /bin/cp "$CONF_TMP/bash_profile"         "$LFS_ROOT/root/.bash_profile"

# ── GRUB ──────────────────────────────────────────────────────────────────────
echo "[INFO] Installing GRUB..."
sudo grub-install \
  --boot-directory=/mnt/lfs-boot/boot \
  --root-directory=/mnt/lfs-boot \
  --target="$GRUB_TARGET" \
  "$LOOP_DEVICE"

echo "[INFO] Copying boot files..."
sudo cp -a "$LFS_WORKDIR/boot/"* /mnt/lfs-boot/

sudo mkdir -p /mnt/lfs-boot/boot/grub
sudo tee "$CONF_TMP/grub.cfg" > /dev/null << EOF
set default=0
set timeout=10

menuentry "DevOpsTribe GNU/Linux, Linux ${LFS_KERNEL_VERSION}-lfs-12.3" {
  set gfxmode=1280x1024
  set gfxpayload=keep
  linux /vmlinuz-${LFS_KERNEL_VERSION}-lfs-12.3 root=/dev/vda2 ro nomodeset debug earlyprintk=efi,keep ${GRUB_CONSOLE}
  initrd /initrd
}
EOF
sudo cp "$CONF_TMP/grub.cfg" /mnt/lfs-boot/boot/grub/grub.cfg

# ── Chroot: password, dracut, init scripts ───────────────────────────────────
echo "[INFO] Mounting virtual filesystems for chroot..."
sudo mount --bind /proc "$LFS_ROOT/proc"
sudo mount --bind /sys "$LFS_ROOT/sys"
sudo mount --bind /dev "$LFS_ROOT/dev"
sudo mount --bind /dev/pts "$LFS_ROOT/dev/pts"

echo "[INFO] Running chroot setup (password, dracut, init scripts)..."
sudo chroot "$LFS_ROOT" /usr/bin/env -i   \
    HOME=/root                  \
    TERM="$TERM"                \
    PS1='(lfs chroot) \u:\w\$ ' \
    PATH=/usr/bin:/usr/sbin     \
    MAKEFLAGS="-j$(nproc)"      \
    /bin/bash -c "

        # TODO: replace with hashed secret or vault
        echo 'luckysideburn.123' | passwd --stdin root

        # dracut gira nel chroot: usa i moduli e le librerie corrette della LFS
        dracut --force \
            --kver ${LFS_KERNEL_VERSION} \
            --add 'bash kernel-modules rootfs-block base' \
            --omit 'systemd' \
            --filesystems 'ext4' \
            --drivers 'virtio_blk virtio_pci' \
            /boot/initrd
    "

sudo cp "$LFS_ROOT/boot/initrd" /mnt/lfs-boot/initrd
echo "[INFO] Chroot setup completed."

echo "[INFO] Unmounting virtual filesystems..."
sudo umount "$LFS_ROOT/dev/pts"
sudo umount "$LFS_ROOT/dev"
sudo umount "$LFS_ROOT/sys"
sudo umount "$LFS_ROOT/proc"

# ── Umount ────────────────────────────────────────────────────────────────────
echo "[INFO] Unmounting partitions..."
sudo umount /mnt/lfs-boot
sudo umount /mnt/lfs-root
sudo losetup -D

# ── Clone immagine ────────────────────────────────────────────────────────────
echo "[INFO] Cloning image to $IMAGE_CLONE_PATH..."
sudo cp -a "$IMAGE_PATH" "$IMAGE_CLONE_PATH"

# ── Crea VM ───────────────────────────────────────────────────────────────────
if [[ "$BUILD_MODE" == "host_libvirt_amd64" ]]; then
  echo "[INFO] Creating VM $VM_NAME..."
  sudo -i -u ubuntu virt-install \
    --name "$VM_NAME" \
    --memory 2048 \
    --disk path="$IMAGE_PATH",format=raw,bus=virtio \
    --os-variant generic \
    --network network="$VIRSH_NETWORK",model=virtio \
    --graphics vnc,listen=0.0.0.0 \
    --video virtio \
    --import \
    --noautoconsole

  echo "[INFO] Creating debug VM $LIVE_VM_NAME..."
  sudo -i -u ubuntu virt-install \
    --name "$LIVE_VM_NAME" \
    --memory 512 \
    --disk path="$LIVE_VM_ISO_PATH",format=raw,bus=ide,device=cdrom \
    --disk path="$IMAGE_CLONE_PATH",format=raw,bus=virtio \
    --os-variant generic \
    --network network="$VIRSH_NETWORK",model=virtio \
    --graphics vnc,listen=0.0.0.0 \
    --import \
    --noautoconsole
fi

# ── Riepilogo ─────────────────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[DONE] All steps completed successfully."
echo "  Main image : $IMAGE_PATH"
echo "  Clone      : $IMAGE_CLONE_PATH (debug)"
echo "  VM         : $VM_NAME"
echo "  Debug VM   : $LIVE_VM_NAME (boots Alpine ISO)"
echo "  Connect    : sudo virsh console $VM_NAME"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"