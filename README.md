# GDt - Generic Distro Toolkit

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

A comprehensive toolkit for building custom GNU/Linux distributions following the Linux From Scratch (LFS) methodology. This project provides automation tools, service management utilities, and infrastructure-as-code solutions for creating and managing custom Linux distributions.

## 🎯 Project Overview

GDt (Generic Distro Toolkit) is a work-in-progress project aimed at simplifying the complex process of building a GNU/Linux operating system from scratch. It combines the educational aspects of Linux From Scratch with modern automation tools to create a reproducible and maintainable build environment.

## 🏗️ Architecture

The project consists of several interconnected components:

### 📁 Project Structure

```
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
