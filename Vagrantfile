# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.ssh.insert_key = false
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.provider :virtualbox do |v|
    v.memory = 1024
    v.cpus = 2
    v.linked_clone = true
  end

  def configure_ubuntu(vm_ubuntu)
    # test out the playbook that installs the basic packages I need on a server
    vm_ubuntu.vm.provision "server_essentials", type: "ansible" do |common_server_essentials|
      common_server_essentials.compatibility_mode = "2.0"
      common_server_essentials.playbook = "playbooks/servers/setup.yml"
    end
    # setup neovim with astronvim
    vm_ubuntu.vm.provision "neovim", type: "ansible" do |neovim_config|
      neovim_config.compatibility_mode = "2.0"
      neovim_config.playbook = "playbooks/devex/neovim.yml"
    end
    # setup tmux
    vm_ubuntu.vm.provision "tmux", type: "ansible" do |tmux_config|
      tmux_config.compatibility_mode = "2.0"
      tmux_config.playbook = "playbooks/devex/tmux.yml"
    end
    #
    # # install devtools
    # # this includes python, installed the way I like it,
    # # rust, golang, fish, fzf, ripgrep, 
    # vm_ubuntu.vm.provision "devtools", type: "ansible" do |devtools_config|
    #   devtools_config.compatibility_mode = "2.0"
    #   devtools_config.playbook = "playbook/devex/devtools.yml"
    # end
  end


  config.vm.define "ubuntu1804", autostart: false do |ubuntu1|
    ubuntu1.vm.box = "hashicorp/bionic64"
    ubuntu1.vm.host_name = "ubuntu1804.test"
    ubuntu1.vm.network "private_network", ip: "192.168.60.2"
    configure_ubuntu ubuntu1
  end

  config.vm.define "ubuntu2004", autostart: false do |ubuntu2|
    ubuntu2.vm.box = "geerlingguy/ubuntu2004"
    ubuntu2.vm.host_name = "ubuntu2004.test"
    ubuntu2.vm.network "private_network", ip: "192.168.60.3"
    configure_ubuntu ubuntu2
  end

  config.vm.define "ubuntu2204", primary: true do |ubuntu3|
    ubuntu3.vm.box = "nickpegg/ubuntu-22.04"
    ubuntu3.vm.host_name = "ubuntu2204.test"
    ubuntu3.vm.network "private_network", ip: "192.168.60.4"
    configure_ubuntu ubuntu3
  end

  config.vm.define "arch1", autostart: false do |arch1|
    arch1.vm.box = "archlinux/archlinux"
    arch1.vm.host_name = "archbtw.test"
    arch1.vm.network "private_network", ip: "192.168.60.5"
  end


end
