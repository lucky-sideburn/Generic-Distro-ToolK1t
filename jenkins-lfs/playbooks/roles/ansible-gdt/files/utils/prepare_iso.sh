#!/bin/bash
# Script to prepare a bootable LFS Live ISO
# Assumes LFS is mounted at /mnt/lfs

# 1. Create workspace
ISO_WORKSPACE="/tmp/lfs_iso_ws"
sudo mkdir -p $ISO_WORKSPACE

# 2. Copy EVERYTHING from your LFS root (except /proc, /sys, /dev)
# Use -a to preserve permissions/symlinks which are critical for LFS
sudo rsync -a --progress \
  --exclude='/root/.cache' \
  --exclude='/sources' \
  --exclude='/root/go' \
  --exclude='/tmp' \
  --exclude='/build' \
  --exclude='/proc/*' \
  --exclude='/sys/*' \
  --exclude='/dev/*' \
  /mnt/lfs/ $ISO_WORKSPACE/

sudo mkdir -p $ISO_WORKSPACE/live

LFS_KERNEL_VERSION="6.13.4" # Change to your exact version
LFS_ROOT="/mnt/lfs"         # Your LFS mount point

sudo dracut --force \
    --kver $LFS_KERNEL_VERSION \
    --kmoddir $LFS_ROOT/lib/modules/$LFS_KERNEL_VERSION \
    --add "dmsquash-live bash kernel-modules rootfs-block base multipath" \
    --omit "systemd" \
    --filesystems "iso9660 squashfs overlay" \
    --drivers "sr_mod sd_mod usb_storage uas cdrom" \
    /tmp/initrd

sudo cp /tmp/initrd $ISO_WORKSPACE/live/initrd
sudo cp /mnt/lfs/boot/vmlinuz-6.13.4-lfs-12.3 $ISO_WORKSPACE/live/vmlinuz

# 4. Create the GRUB config INSIDE the workspace
sudo mkdir -p $ISO_WORKSPACE/boot/grub

sudo tee $ISO_WORKSPACE/boot/grub/grub.cfg << EOF
insmod part_gpt
insmod part_msdos
insmod iso9660
insmod all_video

set default=0
set timeout=5

# GRUB cerca la partizione per caricare Kernel e Initrd
search --no-floppy --set=root --label DEVOPS_ISO

# menuentry "DevOpsTribe GNU/Linux Live" {
#     set gfxpayload=keep
#     linux /live/vmlinuz boot=live root=LABEL=DEVOPS_ISO rootwait quiet splash
#     initrd /live/initrd
# }

menuentry "DevOpsTribe GNU/Linux Live" {
    set gfxpayload=keep
    linux /live/vmlinuz boot=live root=live:LABEL=DEVOPS_ISO rd.live.squashimg=filesystem.squashfs rd.live.image rd.live.overlay.size=2048 rd.live.overlay.overlayfs=1 quiet splash
    initrd /live/initrd
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
# 1:2345:respawn:/sbin/agetty --autologin root --noclear -n tty1 9600
1:2345:respawn:/sbin/agetty tty1 9600
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

# Clean up unnecessary services from the live ISO (temporaty patch)
# TODO: Fix this
sudo rm $ISO_WORKSPACE/etc/rc.d/rcS.d/S45cleanfs
sudo rm $ISO_WORKSPACE/etc/rc.d/rcS.d/S40mountfs
sudo rm $ISO_WORKSPACE/etc/rc.d/rc3.d/S92kubelet  
sudo rm $ISO_WORKSPACE/etc/rc.d/rc3.d/S91crio
sudo rm $ISO_WORKSPACE/etc/rc.d/rc3.d/S30sshd
sudo rm $ISO_WORKSPACE/etc/rc.d/rcS.d/S30checkfs

# Set the hostname
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

sudo cp /mnt/lfs/sources/utils/system-installer.sh $ISO_WORKSPACE/usr/local/bin/system-installer.sh
sudo chmod +x $ISO_WORKSPACE/usr/local/bin/system-installer.sh

> $ISO_WORKSPACE/root/.bashrc 
> $ISO_WORKSPACE/root/.bash_profile

sudo tee -a $ISO_WORKSPACE/root/.bashrc << 'EOF'
# Custom LFS Live ISO Bashrc
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
export PS1="\[\e[1;32m\]\u@\h:\[\e[1;34m\]\w\[\e[0m\]\$ "

alias ask='interpreter --api_base http://localhost:8080/v1 --local'
EOF

sudo tee -a $ISO_WORKSPACE/root/.bash_profile << 'EOF'
# Carica il bashrc se esiste
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi
EOF

cat $ISO_WORKSPACE/root/.bash_profile

sudo chmod +x $ISO_WORKSPACE/etc/rc.d/init.d/hostname

sudo ln -sf ../init.d/hostname $ISO_WORKSPACE/etc/rc.d/rcS.d/S02hostname

sudo mksquashfs /mnt/lfs/ $ISO_WORKSPACE/live/filesystem.squashfs \
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

[ ls $ISO_WORKSPACE/initrd.img-no-kmods] && sudo rm $ISO_WORKSPACE/initrd.img-no-kmods
[ ls $ISO_WORKSPACE/dist ] && sudo rm -rf $ISO_WORKSPACE/dist
[ ls $ISO_WORKSPACE/tools ] && sudo rm -rf $ISO_WORKSPACE/tools

# Create the directory structure for AI models
sudo mkdir -p $ISO_WORKSPACE/opt/ai/models


MODEL_URL="https://huggingface.co/Qwen/Qwen2.5-1.5B-Instruct-GGUF/resolve/main/qwen2.5-1.5b-instruct-q4_k_m.gguf"
MODEL_DEST="$ISO_WORKSPACE/opt/ai/models/qwen2.5-1.5b.gguf"
mkdir -p "$(dirname "$MODEL_DEST")"
curl -L "$MODEL_URL" -o "$MODEL_DEST"

sudo tee $ISO_WORKSPACE/usr/local/bin/start-llama-server << 'EOF'
#!/bin/bash
/usr/local/bin/llama-server \
    -m /opt/ai/models/qwen2.5-1.5b.gguf \
    --port 8080 \
    --host 0.0.0.0 \
    --ctx-size 2048 \
    --n-predict 512 \
    --threads $(nproc) \
    --alias "lfs-agent-brain" \
    2>&1 > /dev/null &
EOF

sudo chmod +x $ISO_WORKSPACE/usr/local/bin/start-llama-server

sudo tee $ISO_WORKSPACE/etc/rc.d/init.d/llama-server << 'EOF'
#!/bin/sh
########################################################################
# Begin llama-server
#
# Description : Start llama-server at boot
#
########################################################################

. /lib/lsb/init-functions

case "${1}" in
   start)
    log_info_msg "Starting llama-server..."
    /usr/local/bin/start-llama-server &
    evaluate_retval
    ;;
   stop)
    log_info_msg "Stopping llama-server..."
    pkill -f llama-server
    evaluate_retval
    ;;
   *)
    echo "Usage: ${0} {start|stop}"
    exit 1
    ;;
esac

# End llama-server
EOF

sudo chmod +x $ISO_WORKSPACE/etc/rc.d/init.d/llama-server
sudo ln -sf ../init.d/llama-server $ISO_WORKSPACE/etc/rc.d/rc3.d/S99llama-server

# Create the Wargames script
sudo tee $ISO_WORKSPACE/usr/local/bin/wargame << 'EOF'
#!/bin/bash

# Effetto digitazione Wargames
function typewriter {
  text="$1"
  for (( i=0; i<${#text}; i++ )); do
    echo -n "${text:$i:1}"
    sleep 0.03
  done
  echo ""
}

if [ -z "$1" ]; then
  typewriter "SALVE PROFESSOR FALKEN."
  typewriter "VUOLE GIOCARE A UNA PARTITA?"
fi

while true; do
  # Prompt the user for input
  echo -n "Inserisci la tua domanda: "
  read USER_INPUT

  # Exit the loop if the user types "exit"
  if [[ "$USER_INPUT" == "exit" ]]; then
    typewriter "ARRIVEDERCI, PROFESSOR FALKEN."
    break
  fi

  # Correzione per llama.cpp
  RESPONSE=$(curl -s http://localhost:8080/completion \
    -H "Content-Type: application/json" \
    -d "{\"prompt\": \"<|system|>Sei HAL... <|user|>$USER_INPUT <|assistant|>\", \"n_predict\": 200}" | jq -r '.content')
    
  typewriter "$RESPONSE"

done
EOF

chmod +x $ISO_WORKSPACE/usr/local/bin/hal
sudo chmod +x $ISO_WORKSPACE/usr/local/bin/wargame

sudo mkdir -p $ISO_WORKSPACE/tmp
sudo chmod 1777 $ISO_WORKSPACE/tmp
sudo mkdir -p $ISO_WORKSPACE/var/log
sudo mkdir -p $ISO_WORKSPACE/run

sudo grub-mkrescue --iso-level 3 \
  -o /var/lib/libvirt/images/lfs-system.iso $ISO_WORKSPACE -- -volid "DEVOPS_ISO" \
     -publisher "DevOpsTribe" \
     -hfsplus off

sudo chown libvirt-qemu:kvm /var/lib/libvirt/images/lfs-system.iso

