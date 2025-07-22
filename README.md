```
# GDT (Generic Distro Toolkit) - Under Development 🚧

What is GDT?
================
The **Generic Distro Toolkit (GDT)** is a cutting-edge project under the **Garanti Del Talento** initiative. It empowers you to craft your own custom GNU/Linux distro from scratch using the power of **Linux From Scratch (LFS)** ([LFS website](https://www.linuxfromscratch.org/)), **Ansible**, and **Jenkins**.

```
OxHrtz - GNU/Linux Distro
==============================
I am working on a GNU/Linux distro called **OxHrtz**, designed to include powerful integration with **containers** and **Kubernetes (k8s)**. This distribution aims to simplify container management and orchestration, making it ideal for cloud-native and DevOps environments.
```
=========================
This project is in active development. Want to join the action? Open a GitHub issue to request access to these elite tools:

- **[Jenkins Instance](https://jenkins.garantideltalento.it/):** Automate package builds and system configurations like a boss.
- **[Cockpit Interface](https://cockpit.garantideltalento.it/):** Get direct console access to your custom OS images.
- **[Redmine Instance](https://academy.garantideltalento.it/):** Track every task in your distro-building journey.

How to Use
=============
🔧 Spin Up Jenkins Jobs with Ansible
------------------------------------
Fire up a Jenkins job with a single command:

    ansible-playbook -i inventories/hosts.ini playbooks/start.yml 

Auto-Generate Redmine Issues for Tools
-----------------------------------------
Let the script do the heavy lifting. Generate Redmine issues for every tool in the compilation pipeline:

    cd playbooks/roles/ansible-gdt/vars
    python3 redmine.py

The LFS Process
-------------------------
Every LFS step and additional configuration is meticulously defined here:  
[main.yml on GitHub](https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml)
```