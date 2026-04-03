# Generic Distro ToolKit (GDT)

An automation framework for building custom Linux distributions from scratch, targeting both AMD64 and AARCH64 architectures. GDT automates the full [Linux From Scratch (LFS)](https://www.linuxfromscratch.org/) build process via Jenkins CI/CD pipelines orchestrated by Ansible — producing minimal, reproducible Linux images with optional Kubernetes and container runtime support.

---

## Overview

GDT manages the end-to-end lifecycle of a custom Linux build:

1. **Infrastructure provisioning** — sets up Jenkins build agents (AMD64 and AARCH64) via Vagrant/Ansible
2. **Jenkins job generation** — creates and configures all pipeline jobs programmatically
3. **Multi-stage LFS build** — compiles cross-toolchain, temporary tools, base system, and optional components in chroot
4. **Package integration** — extracts and compiles EL9/Rocky Linux 9 RPMs for RHEL-compatible packages
5. **Container & Kubernetes support** — installs CRI-O and core Kubernetes components into the image

---

## Architecture

```
Generic-Distro-ToolKit/
├── start.sh                  # Interactive CLI entry point
├── Vagrantfile               # VM definitions (AARCH64 Ubuntu, Rocky Linux 9)
├── hosts.ini                 # Ansible inventory
├── jenkins-lfs/
│   ├── chroot_in.sh          # Helper to enter LFS chroot
│   ├── mounts.sh             # Mount management for LFS directories
│   ├── reset.sh              # Cleanup/reset script
│   ├── playbooks/            # Ansible playbooks (start, amd64_lfs, aarch64_lfs, el9_pkgs, …)
│   ├── roles/ansible-gdt/    # Main Ansible role (tasks, vars, files)
│   │   ├── tasks/            # Job creation tasks per architecture
│   │   ├── vars/             # Jenkins job definitions
│   │   └── files/            # Kernel configs, Kubernetes configs, system files, utilities
│   ├── scripts/              # Python utilities (gen_el9_jobs.py)
│   └── package_maps/         # Package lists (el9_pkgs.tsv, el9_pkgs.json)
└── os_images/                # Output: built ISOs and qcow2 images
```

---

## Build Pipeline

Each architecture runs 9 sequential Jenkins stages:

| Stage | Description |
|-------|-------------|
| `cross_toolchain` | GCC, binutils, cross-compilation toolchain |
| `cross_compiling_temporary_tools` | Temporary utilities for the build host |
| `chroot_and_building_additional_temporary_tools` | Advanced temporary tools inside chroot |
| `basic_system_software` | Core system packages (glibc, bash, coreutils, …) |
| `system_configuration` | System init, environment, and service configuration |
| `containers` | CRI-O container runtime and supporting tools |
| `GenAI` | AI/ML framework integration |
| `systemd_integration` | Systemd unit files and integration |
| `el9_packages` | Rocky Linux 9 / EL9 RPM compilation and installation |

---

## Prerequisites

- **Ansible** (control node)
- **Vagrant** + VirtualBox (for AARCH64 VM) or libvirt (for Rocky Linux 9 VM)
- **Jenkins** instance with API access
- Environment variables:
  - `JENKINS_TOKEN` — Jenkins API token
  - `JENKINS_AGENT_SECRET` — Jenkins agent connection secret

---

## Quick Start

### 1. Launch the interactive menu

```bash
./start.sh
```

The menu provides four sections:

- **Jenkins Setup** — create folder structure
- **AMD64 Jobs** — provision and trigger AMD64 build stages
- **AARCH64 Jobs** — provision and trigger AARCH64 build stages
- **Infrastructure** — VM provisioning and EL9 package map generation

### 2. Provision build nodes (optional, via Vagrant)

```bash
# AARCH64 build agent
vagrant up ubuntu-arm-lfs

# Rocky Linux 9 for EL9 package extraction
vagrant up rocky9-lfs
```

### 3. Generate EL9 package jobs

```bash
python3 jenkins-lfs/scripts/gen_el9_jobs.py
```

This reads `jenkins-lfs/package_maps/el9_pkgs.tsv` and generates numbered Jenkins job definitions.

### 4. Run Ansible playbooks directly

```bash
# Full LFS build — AMD64
ansible-playbook -i hosts.ini jenkins-lfs/playbooks/amd64_lfs.yml

# Full LFS build — AARCH64
ansible-playbook -i hosts.ini jenkins-lfs/playbooks/aarch64_lfs.yml

# Extract EL9 package list from Rocky Linux 9
ansible-playbook -i hosts.ini jenkins-lfs/playbooks/el9_pkgs.yml
```

---

## Key Environment Variables

| Variable | Description |
|----------|-------------|
| `LFS` | LFS build root (default: `/mnt/lfs`) |
| `LFS_TGT` | Cross-compilation target (e.g., `aarch64-lfs-linux-gnu`) |
| `MAKEFLAGS` | Parallel build flag (e.g., `-j$(nproc)`) |
| `JENKINS_TOKEN` | Jenkins API authentication token |
| `JENKINS_AGENT_SECRET` | Jenkins agent connection secret |

---

## Supported Architectures

| Architecture | Host OS | Provisioner |
|-------------|---------|-------------|
| AMD64 (x86_64) | Any Linux | Ansible |
| AARCH64 | Ubuntu 22.04 ARM64 | Vagrant + VirtualBox / QEMU |

---

## Contributing

See [CONTRIBUTING](CONTRIBUTING) for guidelines and the Code of Conduct.

---

## License

Apache 2.0 — see [LICENSE](LICENSE).
