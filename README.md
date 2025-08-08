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
│   │   └── roles/
│   │       └── ansible-gdt/  # Main GDT Ansible role
│   ├── basic_system_software.sh
│   ├── chroot_new.sh        # Chroot environment setup
│   ├── mounts.sh            # Filesystem mounting utilities
│   └── system_configuration.sh
├── service-manager/          # Go-based service management tool
│   ├── main.go              # Terminal UI service manager
│   ├── go.mod               # Go module dependencies
│   └── README.md            # Service manager documentation
├── images/                   # Screenshots and documentation images
└── Vagrantfile              # Development environment setup
```

## 🚀 Features

### Core Components

- **🔧 LFS Build Automation**: Ansible-driven Linux From Scratch build process
- **📊 Service Manager**: Interactive terminal-based service management tool
- **🖥️ VM Management**: KVM/QEMU virtual machine setup and management
- **⚙️ Configuration Management**: Automated system configuration and deployment
- **🐳 Container Support**: CRI-O and Kubernetes integration
- **🔐 Security**: Custom security configurations and hardening

### Build System Features

- **Automated Package Compilation**: Streamlined source code compilation process
- **Dependency Management**: Automatic handling of build dependencies
- **Cross-Architecture Support**: Support for multiple architectures (x86_64, ARM64)
- **Customizable Configurations**: Flexible kernel and system configurations
- **Version Control Integration**: Git-based source management

## 🎮 Usage

### Ansible Automation (create Jenkins Jobs)

```bash
cd jenkins-lfs

# Run the complete build process
ansible-playbook -i inventories/hosts.ini playbooks/start.yml

# Run specific tags
ansible-playbook -i inventories/hosts.ini playbooks/start.yml --tags=basic_system_software
```

## 🔧 Configuration

### Customizing the Build

1. **Kernel Configuration**: Modify `jenkins-lfs/playbooks/roles/ansible-gdt/files/kernel_config_x86_64`
2. **System Services**: Update configurations in `jenkins-lfs/playbooks/roles/ansible-gdt/files/`
...

### VM Configuration

The project supports multiple VM configurations:

- **Development VM**: ARM64 Ubuntu 22.04 (via Vagrant)
- **LFS Build VM**: Custom KVM/QEMU setup
- **Testing Environment**: Automated testing infrastructure

## 🖼️ Screenshots

The project includes visual documentation in the `images/` directory:
- **Cockpit**: Web-based server management interface
- **Jenkins**: Build automation dashboard  
- **Redmine**: Project management interface

## 🤝 Contributing

Contributions are welcome! Please read [CONTRIBUTING](CONTRIBUTING) for guidelines on:

- Code style and standards
- Submitting pull requests
- Reporting issues
- Feature requests

### Development Workflow

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📝 License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## 🔗 Related Projects

- [Linux From Scratch](http://www.linuxfromscratch.org/) - The foundational methodology
- [Ansible](https://www.ansible.com/) - Automation engine
- [Vagrant](https://www.vagrantup.com/) - Development environment management

## 📞 Support & Contact

- **Issues**: [GitHub Issues](https://github.com/lucky-sideburn/Generic-Distro-ToolK1t/issues)
- **Discussions**: [GitHub Discussions](https://github.com/lucky-sideburn/Generic-Distro-ToolK1t/discussions)
- **Author**: [@lucky-sideburn](https://github.com/lucky-sideburn)

## 🚧 Project Status

**Current Status**: Work In Progress

### Completed Features
- ✅ Basic LFS build automation
- ✅ Service management tool
- ✅ VM environment setup
- ✅ Ansible role structure

### In Progress
- 🔄 Container runtime integration
- 🔄 Kubernetes cluster setup
- 🔄 Security hardening
- 🔄 Cross-architecture builds

### Planned Features
- 📋 Package manager integration
- 📋 Update system
- 📋 GUI installer
- 📋 Cloud deployment automation

---

**Note**: This is an educational and experimental project. Use in production environments is not recommended without thorough testing and customization.