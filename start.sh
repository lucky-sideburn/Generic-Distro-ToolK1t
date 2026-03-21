#!/bin/bash

# ─── Colors ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

MAIN_PLAYBOOK_PATH="./jenkins-lfs/playbooks/start.yml"

# ─── Helpers ──────────────────────────────────────────────────────────────────
confirm() {
  local prompt="${1:-Are you sure?}"
  read -rp "$(echo -e "${YELLOW}${prompt} [y/N]: ${RESET}")" ans
  [[ "$ans" =~ ^[Yy]$ ]]
}

print_header() {
  clear
  echo -e "${CYAN}${BOLD}"
  echo "  ╔═══════════════════════════════════════╗"
  echo "  ║    Generic Distro Toolkit             ║"
  echo "  ╚═══════════════════════════════════════╝"
  echo -e "${RESET}"
  # Status panel
  if [ -f jenkins-lfs/inventories/hosts_prod.ini ]; then
    echo -e "  ${GREEN}✔${RESET} hosts_prod.ini found"
  else
    echo -e "  ${RED}✘${RESET} hosts_prod.ini ${RED}NOT found${RESET}"
  fi
  if [ -n "$JENKINS_TOKEN" ]; then
    echo -e "  ${GREEN}✔${RESET} JENKINS_TOKEN is set"
  else
    echo -e "  ${YELLOW}⚠${RESET}  JENKINS_TOKEN is ${YELLOW}not set${RESET}"
  fi
  if [ -d /vagrant ]; then
    echo -e "  ${GREEN}✔${RESET} Running inside Vagrant"
  else
    echo -e "  ${CYAN}ℹ${RESET}  Not inside Vagrant"
  fi
  echo
}

# ─── QEMU BIOS auto-detect ────────────────────────────────────────────────────
detect_bios() {
  local bios
  bios=$(find /opt/homebrew/Cellar/qemu -name "edk2-aarch64-code.fd" 2>/dev/null | sort -V | tail -1)
  if [ -z "$bios" ]; then
    echo -e "${RED}Error: Could not find edk2-aarch64-code.fd under /opt/homebrew/Cellar/qemu${RESET}" >&2
    return 1
  fi
  echo "$bios"
}

# ─── QEMU VM ──────────────────────────────────────────────────────────────────
create_qemu_vm_from_img() {
  local OS_IMAGE_BASE_DIR=./os_images
  local BIOS
  BIOS=$(detect_bios) || return 1

  qemu-img convert -f raw -O qcow2 "$OS_IMAGE_BASE_DIR/lfs.img"       "$OS_IMAGE_BASE_DIR/lfs.qcow2"
  qemu-img convert -f raw -O qcow2 "$OS_IMAGE_BASE_DIR/lfs-clone.img" "$OS_IMAGE_BASE_DIR/lfs-clone.qcow2"

  echo -e "${CYAN}Starting Alpine Linux that mounts the LFS image for debugging...${RESET}"
  qemu-system-aarch64 \
      -M virt -cpu host -accel hvf -smp 2 -m 2048 \
      -drive file="$OS_IMAGE_BASE_DIR/alpine.iso",if=virtio,media=cdrom \
      -drive file="$OS_IMAGE_BASE_DIR/lfs-clone.qcow2",if=virtio,format=qcow2 \
      -drive file="$OS_IMAGE_BASE_DIR/lfs.qcow2",if=virtio,format=qcow2 \
      -netdev user,id=net0,hostfwd=tcp::2222-:22 \
      -device virtio-net-device,netdev=net0 \
      -device virtio-gpu-pci -device VGA -device usb-ehci -device usb-kbd \
      -display cocoa -bios "$BIOS" -serial mon:stdio -boot d

  echo -e "${CYAN}Starting the AARCH64 VM with the LFS image...${RESET}"
  qemu-system-aarch64 \
      -M virt -cpu host -accel hvf -smp 2 -m 2048 \
      -drive file="$OS_IMAGE_BASE_DIR/lfs.qcow2",if=virtio,format=qcow2 \
      -netdev user,id=net0,hostfwd=tcp::2222-:22 \
      -device virtio-net-device,netdev=net0 \
      -device virtio-gpu-pci -device VGA -device usb-ehci -device usb-kbd \
      -display cocoa -bios "$BIOS" -serial mon:stdio -boot c
}

# ─── Ansible wrapper ──────────────────────────────────────────────────────────
ansible_cmd() {
  if ! command -v ansible-playbook &> /dev/null; then
    echo -e "${RED}Error: 'ansible-playbook' not found. Please install Ansible.${RESET}"
    return 1
  fi
  if [ ! -f jenkins-lfs/inventories/hosts_prod.ini ]; then
    echo -e "${RED}Error: hosts_prod.ini not found in jenkins-lfs/inventories/${RESET}"
    echo "Create it from jenkins-lfs/inventories/hosts.ini (it contains secrets)."
    return 1
  fi

  local -a extra=()
  if [ -d /vagrant ]; then
    echo -e "${YELLOW}Inside Vagrant — using local connection.${RESET}"
    extra+=(-e ansible_connection=local)
  fi
  if [ -n "$JENKINS_TOKEN" ]; then
    echo -e "${GREEN}Using JENKINS_TOKEN from environment.${RESET}"
    extra+=(-e "jenkins_token=$JENKINS_TOKEN")
  fi

  echo -e "${CYAN}Running:${RESET} ansible-playbook ${extra[*]} -v -i jenkins-lfs/inventories/hosts_prod.ini $*"
  echo
  ansible-playbook "${extra[@]}" -v -i jenkins-lfs/inventories/hosts_prod.ini "$@"
}

# ─── Sub-menus ────────────────────────────────────────────────────────────────
menu_amd64() {
  while true; do
    echo
    echo -e "${BOLD}── AMD64 Jobs ──────────────────────────────────────────${RESET}"
    echo "  0) All AMD64 Jobs"
    echo "  1) cross_toolchain"
    echo "  2) cross_compiling_temporary_tools"
    echo "  3) chroot_and_building_additional_temporary_tools"
    echo "  4) basic_system_software"
    echo "  5) system_configuration"
    echo "  6) containers"
    echo "  7) GenAI"
    echo "  8) Systemd Integration"
    echo "  9) EL9 Packages"
    echo "  b) Back"
    echo
    read -rp "$(echo -e "${BOLD}Choice: ${RESET}")" choice
    case $choice in
      0) confirm "Build ALL AMD64 jobs?" && ansible_cmd "$MAIN_PLAYBOOK_PATH" --tags amd64_jobs ;;
      1) ansible_cmd "$MAIN_PLAYBOOK_PATH" --tags amd64_cross_toolchain ;;
      2) ansible_cmd "$MAIN_PLAYBOOK_PATH" --tags amd64_cross_compiling_temporary_tools ;;
      3) ansible_cmd "$MAIN_PLAYBOOK_PATH" --tags amd64_chroot_and_building_additional_temporary_tools ;;
      4) ansible_cmd "$MAIN_PLAYBOOK_PATH" --tags amd64_basic_system_software ;;
      5) ansible_cmd "$MAIN_PLAYBOOK_PATH" --tags amd64_system_configuration ;;
      6) ansible_cmd "$MAIN_PLAYBOOK_PATH" --tags amd64_containers ;;
      7) ansible_cmd "$MAIN_PLAYBOOK_PATH" --tags amd64_genai ;;
      8) ansible_cmd "$MAIN_PLAYBOOK_PATH" --tags amd64_systemd_integration ;;
      9) ansible_cmd "$MAIN_PLAYBOOK_PATH" --tags amd64_el9_packages ;;
      b|B) return ;;
      *) echo -e "${RED}Invalid choice.${RESET}" ;;
    esac
  done
}

menu_aarch64() {
  while true; do
    echo
    echo -e "${BOLD}── AARCH64 Jobs ────────────────────────────────────────${RESET}"
    echo "  0) All AARCH64 Jobs"
    echo "  1) cross_toolchain"
    echo "  2) cross_compiling_temporary_tools"
    echo "  3) chroot_and_building_additional_temporary_tools"
    echo "  4) basic_system_software"
    echo "  5) system_configuration"
    echo "  6) containers"
    echo "  7) GenAI"
    echo "  8) Systemd Integration"
    echo "  9) EL9 Packages"
    echo "  b) Back"
    echo
    read -rp "$(echo -e "${BOLD}Choice: ${RESET}")" choice
    case $choice in
      0) confirm "Build ALL AARCH64 jobs?" && ansible_cmd "$MAIN_PLAYBOOK_PATH" --tags aarch64_jobs ;;
      1) ansible_cmd "$MAIN_PLAYBOOK_PATH" --tags aarch64_cross_toolchain ;;
      2) ansible_cmd "$MAIN_PLAYBOOK_PATH" --tags aarch64_cross_compiling_temporary_tools ;;
      3) ansible_cmd "$MAIN_PLAYBOOK_PATH" --tags aarch64_chroot_and_building_additional_temporary_tools ;;
      4) ansible_cmd "$MAIN_PLAYBOOK_PATH" --tags aarch64_basic_system_software ;;
      5) ansible_cmd "$MAIN_PLAYBOOK_PATH" --tags aarch64_system_configuration ;;
      6) ansible_cmd "$MAIN_PLAYBOOK_PATH" --tags aarch64_containers ;;
      7) ansible_cmd "$MAIN_PLAYBOOK_PATH" --tags aarch64_genai ;;
      8) ansible_cmd "$MAIN_PLAYBOOK_PATH" --tags aarch64_systemd_integration ;;
      9) ansible_cmd "$MAIN_PLAYBOOK_PATH" --tags aarch64_el9_packages ;;
      b|B) return ;;
      *) echo -e "${RED}Invalid choice.${RESET}" ;;
    esac
  done
}

menu_infra() {
  while true; do
    echo
    echo -e "${BOLD}── Infrastructure ──────────────────────────────────────${RESET}"
    echo "  1) Start AARCH64 VM on QEMU"
    echo "  2) Provision AARCH64 build node (Vagrant)"
    echo "  3) Provision AMD64 build node (Ansible)"
    echo "  4) Copy Kernel Configs"
    echo "  5) Copy System Configs"
    echo "  6) Create EL9 packages map (Rocky/libvirt)"
    echo "  7) Generate EL9 Jenkins jobs into main.yml"
    echo "  b) Back"
    echo
    read -rp "$(echo -e "${BOLD}Choice: ${RESET}")" choice
    case $choice in
      1)
        confirm "Start AARCH64 QEMU VM?" && create_qemu_vm_from_img
        ;;
      2)
        confirm "Provision AARCH64 build node via Vagrant?" || continue
        [ -f Vagrantfile ] || { echo -e "${RED}Error: Vagrantfile not found.${RESET}"; continue; }
        if ! vagrant status | grep -q "running"; then
          echo "Vagrant VM not running — starting with 'vagrant up'..."
          vagrant up
        else
          echo "Vagrant VM already running."
        fi
        vagrant provision
        ;;
      3)
        confirm "Provision AMD64 build node via Ansible?" && \
          ansible-playbook -i jenkins-lfs/inventories/hosts_prod.ini jenkins-lfs/playbooks/amd64_lfs.yml
        ;;
      4) ansible_cmd jenkins-lfs/playbooks/kernel_configs.yml ;;
      5) ansible_cmd jenkins-lfs/playbooks/system_conf.yml ;;
      6)
        confirm "Create EL9 packages map using rocky9-lfs (libvirt)?" || continue
        [ -f Vagrantfile ] || { echo -e "${RED}Error: Vagrantfile not found.${RESET}"; continue; }
        echo -e "${CYAN}Starting rocky9-lfs with libvirt...${RESET}"
        if ! VAGRANT_DEFAULT_PROVIDER=libvirt vagrant up rocky9-lfs --no-provision; then
          echo -e "${RED}Error: Failed to start rocky9-lfs with libvirt.${RESET}"
          continue
        fi
        echo -e "${CYAN}Running EL9 package map provisioning...${RESET}"
        if ! VAGRANT_DEFAULT_PROVIDER=libvirt vagrant provision rocky9-lfs --provision-with ansible; then
          echo -e "${RED}Error: Failed to provision rocky9-lfs for EL9 package map generation.${RESET}"
          continue
        fi
        echo -e "${CYAN}Copying EL9 package maps from VM to host...${RESET}"
        VAGRANT_DEFAULT_PROVIDER=libvirt vagrant ssh rocky9-lfs -c "cat /vagrant/jenkins-lfs/package_maps/el9_pkgs.tsv" > jenkins-lfs/package_maps/el9_pkgs.tsv
        VAGRANT_DEFAULT_PROVIDER=libvirt vagrant ssh rocky9-lfs -c "cat /vagrant/jenkins-lfs/package_maps/el9_pkgs.json" > jenkins-lfs/package_maps/el9_pkgs.json
        echo -e "${GREEN}✔ EL9 package maps copied to local repo${RESET}"
        echo -e "${CYAN}Adding and committing EL9 package maps to git...${RESET}"
        if git add jenkins-lfs/package_maps/el9_pkgs.* && \
           git commit -m "chore: update EL9 package maps from Rocky Linux 9"; then
          echo -e "${GREEN}✔ EL9 package maps committed to git${RESET}"
        else
          echo -e "${YELLOW}⚠ Could not commit (files may not have changed, or git error)${RESET}"
        fi
        ;;
      7)
        confirm "Generate EL9 Jenkins jobs into main.yml?" || continue
        if [ ! -f jenkins-lfs/package_maps/el9_pkgs.tsv ]; then
          echo -e "${RED}Error: el9_pkgs.tsv not found. Run option 6 first.${RESET}"
          continue
        fi
        echo -e "${CYAN}Generating EL9 Jenkins job blocks in main.yml...${RESET}"
        if python3 jenkins-lfs/scripts/gen_el9_jobs.py; then
          echo -e "${GREEN}✔ EL9 Jenkins jobs appended to main.yml${RESET}"
          git add jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml && \
            git commit -m "chore: append EL9 Jenkins job blocks from el9_pkgs baseline" && \
            echo -e "${GREEN}✔ Committed to git${RESET}" || \
            echo -e "${YELLOW}⚠ Could not commit (no changes or git error)${RESET}"
        else
          echo -e "${RED}Error: Failed to generate EL9 jobs${RESET}"
        fi
        ;;
      b|B) return ;;
      *) echo -e "${RED}Invalid choice.${RESET}" ;;
    esac
  done
}

# ─── Main ─────────────────────────────────────────────────────────────────────
print_header

while true; do
  echo -e "${BOLD}── Main Menu ───────────────────────────────────────────${RESET}"
  echo "  1) Jenkins Setup   (create folders)"
  echo "  2) AMD64 Jobs"
  echo "  3) AARCH64 Jobs"
  echo "  4) Infrastructure"
  echo "  q) Quit"
  echo
  read -rp "$(echo -e "${BOLD}Choice: ${RESET}")" choice
  echo
  case $choice in
    1)
      confirm "Create Jenkins folders (AMD64 + AARCH64)?" && \
        ansible_cmd "$MAIN_PLAYBOOK_PATH" --tags amd64_folders,aarch64_folders
      ;;
    2) menu_amd64 ;;
    3) menu_aarch64 ;;
    4) menu_infra ;;
    q|Q)
      echo -e "${GREEN}Bye!${RESET}"
      exit 0
      ;;
    *) echo -e "${RED}Invalid choice.${RESET}" ;;
  esac
  echo
done
