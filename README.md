# GDt - Generic Distro Toolkit

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

A comprehensive toolkit for building custom GNU/Linux distributions following the Linux From Scratch (LFS) methodology. This project provides automation tools, service management utilities, and infrastructure-as-code solutions for creating and managing custom Linux distributions.

## Project Overview

GDt (Generic Distro Toolkit) is a work-in-progress project aimed at simplifying the complex process of building a GNU/Linux operating system from scratch. It combines the educational aspects of Linux From Scratch with modern automation tools to create a reproducible and maintainable build environment.

### Step 1 - Create Jenkins Folder

```bash

ubuntu@ns3137793:~/gdt$ bash start.sh 

=========================================
 Welcome to the Generic Distro Toolkit! 
=========================================

Inventory file found. Proceeding...

Select an option:
0)  Create Jenkins Folders
1)  Build AMD64 all Jenkins Jobs
2)  Build AMD64 cross_toolchain Jenkins Jobs
3)  Build AMD64 cross_compiling_temporary_tools Jenkins Jobs
4)  Build AMD64 chroot_and_building_additional_temporary_tools Jenkins Jobs
5)  Build AMD64 basic_system_software Jenkins Jobs
6)  Build AMD64 system_configuration Jenkins Jobs
7)  Build AMD64 containers Jenkins Jobs
8)  Build AARCH64 all Jenkins Jobs
9)  Build AARCH64 cross_toolchain Jenkins Jobs
10) Build AARCH64 cross_compiling_temporary_tools Jenkins Jobs
11) Build AARCH64 chroot_and_building_additional_temporary_tools Jenkins Jobs
12) Build AARCH64 basic_system_software Jenkins Jobs
13) Build AARCH64 system_configuration Jenkins Jobs
14) Build AARCH64 containers Jenkins Jobs
15) Exit

Enter your choice: 0
Building Jenkins Folders...

PLAY [Create GNU/Linux GDT (Garanti Del Talento)] **********************************************************************************************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************************************************************************************************************************
ok: [localhost]

TASK [ansible-gdt : Include aarch64_jobs.yml tasks] ********************************************************************************************************************************************************************************************************************
included: /home/ubuntu/gdt/jenkins-lfs/playbooks/roles/ansible-gdt/tasks/aarch64_jobs.yml for localhost

TASK [ansible-gdt : Create Jenkins Folder (aarch64)] *******************************************************************************************************************************************************************************************************************
ok: [localhost] => (item=aarch64_cross_toolchain)
ok: [localhost] => (item=aarch64_cross_compiling_temporary_tools)
ok: [localhost] => (item=aarch64_chroot_and_building_additional_temporary_tools)
ok: [localhost] => (item=aarch64_basic_system_software)
ok: [localhost] => (item=aarch64_system_configuration)
ok: [localhost] => (item=aarch64_containers)

TASK [ansible-gdt : Include amd64_jobs.yml tasks] **********************************************************************************************************************************************************************************************************************
included: /home/ubuntu/gdt/jenkins-lfs/playbooks/roles/ansible-gdt/tasks/amd64_jobs.yml for localhost

TASK [ansible-gdt : Create Jenkins Folder (amd64)] *********************************************************************************************************************************************************************************************************************
ok: [localhost] => (item=amd64_cross_toolchain)
ok: [localhost] => (item=amd64_cross_compiling_temporary_tools)
ok: [localhost] => (item=amd64_chroot_and_building_additional_temporary_tools)
ok: [localhost] => (item=amd64_basic_system_software)
ok: [localhost] => (item=amd64_system_configuration)
ok: [localhost] => (item=amd64_containers)

PLAY RECAP *************************************************************************************************************************************************************************************************************************************************************
localhost                  : ok=5    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

```

### Project Structure

```bash
Generic-Distro-ToolK1t/
├── jenkins-lfs/              # LFS build automation
│   ├── playbooks/            # Ansible playbooks for system setup
│       └── roles/
│           └── ansible-gdt/  # Main GDT Ansible role
│ 
├── service-manager/         # Go-based service management tool
│   ├── main.go              # Terminal UI service manager
│   ├── go.mod               # Go module dependencies
│   └── README.md            # Service manager documentation
├── images/                  # Screenshots and documentation images
└── Vagrantfile              # Development environment setup
```
