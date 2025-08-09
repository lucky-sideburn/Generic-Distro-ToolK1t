# GDt - Generic Distro Toolkit

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

A comprehensive toolkit for building custom GNU/Linux distributions following the Linux From Scratch (LFS) methodology. This project provides automation tools, service management utilities, and infrastructure-as-code solutions for creating and managing custom Linux distributions.

## Project Overview

GDt (Generic Distro Toolkit) is a work-in-progress project aimed at simplifying the complex process of building a GNU/Linux operating system from scratch. It combines the educational aspects of Linux From Scratch with modern automation tools to create a reproducible and maintainable build environment.

### Playbook Selection for architecture and build section

The project consists of several interconnected components:

```bash

ubuntu@foobar:~/gdt$ bash start.sh

=========================================
 Welcome to the Generic Distro Toolkit! 
=========================================

Inventory file found. Proceeding...

Select an option:
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
