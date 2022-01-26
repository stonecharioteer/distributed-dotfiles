# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.ssh.insert_key = false
  config.vm.synced_folder ".", "/vagrant", disabled: true
  
  config.vm.provider :virtualbox do |v|
    # v.memory = 256
    v.linked_clone = true
  end

  config.vm.define "ubuntu1804" do |ubuntu1|
    ubuntu1.vm.box = "hashicorp/bionic64"
    ubuntu1.vm.host_name = "ubuntu1804.test"
    ubuntu1.vm.network "private_network", ip: "192.168.60.2"
  end

  config.vm.define "ubuntu2004" do |ubuntu2|
    ubuntu2.vm.box = "geerlingguy/ubuntu2004"
    ubuntu2.vm.host_name = "ubuntu2004.test"
    ubuntu2.vm.network "private_network", ip: "192.168.60.3"
  end

  config.vm.define "ubuntu2104" do |ubuntu2|
    ubuntu2.vm.box = "bento/ubuntu-21.04"
    ubuntu2.vm.host_name = "ubuntu2104.test"
    ubuntu2.vm.network "private_network", ip: "192.168.60.4"
  end

  config.vm.define "arch1" do |arch1|
    arch1.vm.box = "archlinux/archlinux"
    arch1.vm.host_name = "archbtw.test"
    arch1.vm.network "private_network", ip: "192.168.60.5"
  end

end
