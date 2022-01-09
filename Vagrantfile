# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.define "ubuntu1" do |ubuntu1|
    ubuntu1.vm.box = "hashicorp/bionic64"
    ubuntu1.vm.host_name = "ubuntu1804"
    ubuntu1.vm.network "private_network", ip: "192.168.60.2"
  end

  config.vm.define "ubuntu2" do |ubuntu2|
    ubuntu2.vm.box = "bento/ubuntu-21.04"
    ubuntu2.vm.host_name = "ubuntu2104"
    ubuntu2.vm.network "private_network", ip: "192.168.60.3"
  end

  config.vm.define "arch1" do |arch1|
    arch1.vm.box = "archlinux/archlinux"
    arch1.vm.host_name = "archbtw"
    arch1.vm.network "private_network", ip: "192.168.60.4"
  end

end
