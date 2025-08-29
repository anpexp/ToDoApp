# -*- mode: ruby -*-
# vi: set ft=ruby :
# 2 VMs (dev/test and prod) on Ubuntu 20.04 (focal64) with Docker & Docker Compose v2
# Provider: VirtualBox

REPO_URL = ENV.fetch('TODO_REPO_URL', 'https://github.com/jospina1001/todoapp')
DOCKERHUB_REPO = ENV.fetch('DOCKERHUB_REPO', 'yourdockerhubuser/todoapp') # e.g. "andrespoveda/todoapp"

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"
  config.vm.synced_folder ".", "/vagrant", type: "virtualbox"

  config.vm.provider "virtualbox" do |vb|
    vb.memory = 2048
    vb.cpus = 2
  end

  # ---- DEV / TEST VM ----
  config.vm.define "dev" do |dev|
    dev.vm.hostname = "todo-dev"
    dev.vm.network "private_network", ip: "192.168.56.10"
    dev.vm.network "forwarded_port", guest: 3000, host: 3000, auto_correct: true # web app (adjust as needed)

    dev.vm.provision "shell", path: "provision/install_docker.sh"
    dev.vm.provision "shell", path: "provision/dev_provision.sh", args: [REPO_URL]
  end

  # ---- DEPLOYMENT VM ----
  config.vm.define "prod" do |prod|
    prod.vm.hostname = "todo-prod"
    prod.vm.network "private_network", ip: "192.168.56.20"
    prod.vm.network "forwarded_port", guest: 3000, host: 8080, auto_correct: true # expose prod on host:8080

    prod.vm.provision "shell", path: "provision/install_docker.sh"
    prod.vm.provision "shell", path: "provision/prod_provision.sh", args: [DOCKERHUB_REPO]
  end
end
