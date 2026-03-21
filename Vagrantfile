# Vagrantfile for Ubuntu ARM

if ENV['JENKINS_TOKEN'].nil? || ENV['JENKINS_TOKEN'].empty?
  STDERR.puts "Warning: Environment variable JENKINS_TOKEN is not set. Jenkins slave provisioning via Ansible may not work as expected."
end

Vagrant.configure("2") do |config|
  config.vm.define "ubuntu-arm-lfs" do |ubuntu|
    ubuntu.vm.box = "arm64-boxes/ubuntu-22.04"
    ubuntu.vm.box_version = "0.2"
    ubuntu.vm.hostname = "ubuntu-arm-lfs"
    ubuntu.vm.synced_folder "os_images/", "/mnt/os_images"
    ubuntu.vm.provider "virtualbox" do |vb|
      vb.memory = "12288"
      vb.cpus = 4
    end

    ubuntu.vm.provision "ansible" do |ansible|
      ansible.playbook = "./jenkins-lfs/playbooks/aarch64_lfs.yml"
      ansible.become = true
      ansible.extra_vars = {
        "jenkins_agent_jar" => "/opt/jenkins/agent/agent.jar",
        "jenkins_master_url" => "https://jenkins.garantideltalento.it",
        "jenkins_user" => "jenkins",
        "jenkins_group" => "jenkins",
        "jenkins_agent_workdir" => "/opt/jenkins/workdir",
        "jenkins_agent_home" => "/opt/jenkins/home",
        "jenkins_agent_name" => "ubuntu-arm-lfs",
        "jenkins_agent_secret" => ENV['JENKINS_AGENT_SECRET'],
        "jenkins_download_lfs_archives" => ENV['JENKINS_DOWNLOAD_LFS_ARCHIVES'] || true,
        "lfs_repo_url" => "http://repo.garantideltalento.it",
      }
    end

    ubuntu.vm.network "private_network", type: "dhcp"
  end

  config.vm.define "rocky9-lfs" do |rocky|
    rocky.vm.box = "generic/rocky9"
    rocky.vm.hostname = "rocky9-lfs"
    rocky.vm.synced_folder "os_images/", "/mnt/os_images"
    rocky.vm.provider "libvirt" do |libvirt|
      libvirt.memory = "40960"
      libvirt.cpus = 2
    end
    rocky.vm.network "private_network", type: "dhcp"
  end
end
