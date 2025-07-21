# GDT (Generic Distro Toolkit) - Work in progress...

## Description
The Generic Distro Toolkit (GDT) is part of the Garanti Del Talento initiative. It facilitates the creation of a custom GNU/Linux distribution based on Linux From Scratch (LFS) ([LFS website](https://www.linuxfromscratch.org/)) by using Ansible and Jenkins.


- [Binutils - Pass 1 (Cross Toolchain) ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [GCC-14.2.0 - Pass 1 (Cross Toolchain) ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Linux-6.13.4 API Headers (Cross Toolchain)  ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Glibc-2.41 (Cross Toolchain)    ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Libstdc++ from GCC-14.2.0 (Cross Toolchain)  ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [M4-1.4.19 (Cross Compiling Temporary Tools)  ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Ncurses-6.5 (Cross Compiling Temporary Tools)  ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Bash-5.2.37 (Cross Compiling Temporary Tools)  ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Coreutils-9.6 (Cross Compiling Temporary Tools)  ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Diffutils-3.11 (Cross Compiling Temporary Tools)  ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [File-5.46 (Cross Compiling Temporary Tools)  ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Findutils-4.10.0 (Cross Compiling Temporary Tools)  ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Gawk-5.3.1 (Cross Compiling Temporary Tools)  ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Grep-3.11 (Cross Compiling Temporary Tools)  ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Gzip-1.13 (Cross Compiling Temporary Tools)  ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Make-4.4.1 (Cross Compiling Temporary Tools)  ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Patch-2.7.6 (Cross Compiling Temporary Tools)  ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Sed-4.9 (Cross Compiling Temporary Tools)  ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Tar-1.35 (Cross Compiling Temporary Tools)  ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Xz-5.6.4 (Cross Compiling Temporary Tools)  ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Binutils-2.44 - Pass 2 (Cross Compiling Temporary](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [GCC-14.2.0 - Pass 2 (Cross Compiling Temporary](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Changing Ownership (Chroot and Building Additional Temporary](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Gettext-0.24 (Chroot and Building Additional Temporary Tools)](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Bison-3.8.2 (Chroot and Building Additional Temporary Tools)](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Perl-5.40.1 (Chroot and Building Additional Temporary Tools)](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Python-3.13.2 (Chroot and Building Additional Temporary Tools)](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Texinfo-7.2 (Chroot and Building Additional Temporary Tools)](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Util-linux-2.40.4 (Chroot and Building Additional Temporary Tools)](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Man-pages-6.12 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Iana-Etc-20250123 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Glibc-2.41 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [glib-2.84.3 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Zlib-1.3.1 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Bzip2-1.0.8 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Xz-5.6.4 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Lz4-1.10.0 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Zstd-1.5.7 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [File-5.46 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Readline-8.2.13 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [M4-1.4.19 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Bc-7.0.3 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Flex-2.6.4 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Tcl-8.6.16 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Expect-5.45.4 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [DejaGNU-1.6.3 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Pkgconf-2.3.0 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Binutils-2.44 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [GMP-6.3.0 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [MPFR-4.2.1 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [MPC-1.3.1 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Attr-2.5.2 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Acl-2.3.2 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Libcap-2.73 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Libxcrypt-4.4.38 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Shadow-4.17.3 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [GCC-14.2.0 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Ncurses-6.5 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Sed-4.9 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Psmisc-23.7 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Gettext-0.24 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Bison-3.8.2 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Grep-3.11 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Bash-5.2.37 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Libtool-2.5.4 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [GDBM-1.24 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Gperf-3.1 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Expat-2.7.1(Basic System Software)    ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Inetutils-2.6 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Less-668 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Perl-5.40.1 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [XML_Parser-2.47 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Intltool-0.51.0 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Autoconf-2.72 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Automake-1.17 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [OpenSSL-3.4.1 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Libelf from Elfutils-0.192 (Basic System Software) ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Libffi-3.4.7 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Python-3.13.2 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Flit-Core-3.11.0 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Wheel-0.45.1 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Setuptools-75.8.1 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Ninja-1.12.1 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Meson-1.7.0 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Kmod-34 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Coreutils-9.6 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Check-0.15.2 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Diffutils-3.11 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Gawk-5.3.1 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Findutils-4.10.0 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Groff-1.23.0 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [GRUB-2.12 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Gzip-1.13 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [IPRoute2-6.13.0 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Kbd-2.7.1 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Libpipeline-1.5.8 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Make-4.4.1 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Patch-2.7.6 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Tar-1.35 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Texinfo-7.2 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Vim-9.1.1166 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [MarkupSafe-3.0.2 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Jinja2-3.1.5 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Udev from Systemd-257.3 (Basic System Software) ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Man-DB-2.13.0 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Procps-ng-4.0.5 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Util-linux-2.40.4 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Pkg-config 0.29.2 (Basic System Software)  ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [E2fsprogs-1.47.2 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Sysklogd-2.7.0 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [SysVinit-3.14 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Stripping (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [libgcrypt-1.11.1 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [libksba-1.6.7 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [npth-1.8 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [libgpg-error-1.55 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [gpgme-2.0.0 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [libassuan-3.0.2 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [gnupg-2.4.8 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Cleaning Up (Basic System Software)  ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [go1.24 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [conmon-v2.1.13 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [libpsl-0.21.5 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [libidn2-2.3.8 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [libunistring-1.3 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [curl-8.15.0 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [LFS-Bootscripts-20240825 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Linux-6.13.4 (Basic System Software)   ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [git-2.49.0      ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [openssh-10.0p1      ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [libtasn1-4.20.0      ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [p11-kit-0.25.5      ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [make-ca-1.16.1 (Certificate Authorities)    ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [Prepare System Image    ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [libseccomp-2.6.0      ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [runc-1.3.0      ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [cri-o-1.33.1      ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [etcd-3.6.1      ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [kubernetes-1.33      ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
- [kubernetes-setup      ](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)

### Toolkit as Jenkins Jobs
![Jenkins Interface](images/jenkins.png)

### Cockpit for Testing the OS Image
![Cockpit Dashboard](images/cockpit.png)

### Redmine Issues for tracking
![Redmine Issues](images/redmine.png)

## Usage

### Create Jenkins Job via Ansible

Run the following command to create a Jenkins job using Ansible:

```bash
ansible-playbook -i inventories/hosts.ini playbooks/start.yml 
```

### Generate Redmine Issues for Tools Compilation

To generate Redmine issues for each tool that needs to be compiled, run:

```bash
cd playbooks/roles/ansible-gdt/vars
python3 redmine.py
```

### LFS Steps and Additional Configurations

Each step of the LFS process, along with extra configurations, is defined in the following file:  
[main.yml on GitHub](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)