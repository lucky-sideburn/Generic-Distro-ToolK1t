            Generic Distro Toolkit (GDT) - Under Development 🚧
========================================================================

What is GDT?
------------
The *Generic Distro Toolkit (GDT)* is a cutting-edge project under the
**Garanti Del Talento** initiative. It empowers you to craft your own
custom GNU/Linux distro from scratch using the power of:

  - Linux From Scratch (LFS): https://www.linuxfromscratch.org/
  - Ansible
  - Jenkins

OxHrtz - GNU/Linux Distro
-------------------------
Working on **OxHrtz**, a GNU/Linux distro designed for powerful container
and Kubernetes (k8s) integration.

A distro that simplifies container management and orchestration,
perfect for cloud-native and DevOps warriors.

========================================================================
*This project is LIVE and cooking!*  

Wanna join the elite? Open a GitHub issue for access to these tools:

  - Jenkins Instance:  https://jenkins.garantideltalento.it/
      Automate builds and system config like a boss.
  
  - Cockpit Interface: https://cockpit.garantideltalento.it/
      Direct console access to your custom OS images.
  
  - Redmine Instance:  https://academy.garantideltalento.it/
      Track every mission in your distro-building campaign.

========================================================================
How to Use
----------

🔧 Spin Up Jenkins Jobs with Ansible
------------------------------------
Just one command to launch:

    ansible-playbook -i inventories/hosts.ini playbooks/start.yml

Auto-Generate Redmine Issues for Tools
--------------------------------------
Let the bots work for you:

    cd playbooks/roles/ansible-gdt/vars
    python3 redmine.py

The LFS Process
---------------
Every LFS step & extra config detailed here:

  https://github.com/lucky-sideburn/gdt/blob/main/jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml

========================================================================
⚠️ WARNING: This toolkit is under heavy development.
Pull requests welcome.
========================================================================