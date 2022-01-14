=============================
Distributed Dotfiles
=============================

I use a fairly customized setup for my servers and development machines.
This repository allows me to provision said machines fairly easily. I use
Ansible for all the provisioning, and I've divided my dotfile configs into
separate repositories because I like to use some shared dotfiles, like the
neovim config from my friend `Rohit. <https://github.com/kvrohit/dotfiles>`_
This way, we can have a shared dotfile config and we can separate things out
to include what each other likes or dislikes.

------------------
Setup
------------------

First, clone this repository and all its submodules.

.. code:: bash
   git clone --recurse-submodules -j8 git@github.com:stonecharioteer/distributed-dotfiles 

If you've already cloned the repo and want to update the submodules or pull them later,


.. code:: bash
   git update --recurse-submodules
   git submodule update --recursive


Install ansible and other dependencies on the host machine.

.. code:: bash

   sudo apt-get install ansible

Testing
---------

If you want to test the playbooks locally first, then install Virtualbox and Vagrant.

.. code:: bash

   sudo apt-get install sshpass vagrant virtualbox

I've included the hosts file and the ``ansible.cfg`` file so that you can use them with it.

**Note that I'm using ``192.168.60.*`` for the private network, so if your network uses it,
be sure to select something else!**

Then, run ``vagrant up`` to bring up the virtual machines. Next, run the
following ansible command.

.. code:: bash
   ansible-playbooks playbooks/servers.yml

You can choose any of the other servers but this is the easiest. Once you're done testing, or
if you want to get rid of the machines, run the following command.

.. code:: bash
   vagrant destroy -f

**Remember to remove the entries from your ``known_hosts`` files.** If you've used my values,
you can run the following.

.. code:: bash

   ssh-keygen -R "192.168.60.2"
   ssh-keygen -R "192.168.60.3"
   ssh-keygen -R "192.168.60.4"

Note that I prefer either Ubuntu or Manjaro/Archlinux for my development machines, and
mostly Ubuntu for my servers. My playbooks should reflect this. If you'd like to add
additional OSes, you should also add to the Vagrantfile and associated files
for easier testing. Additionally, testing ARM machines using Vagrant won't be possible.
It might be better to spin up Raspbian using docker and then try the ansible files. However,
since Raspbian uses Debian underneath, it might be easier to account for those packages
which are Debian specific.

When doing this sort of testing repeatedly, you might want to use the ``--flush-cache``
flag for the ansible commands.

-------------------
Structure
-------------------

I prefer breaking my playbooks into the following:

1. ``servers.yml``: This contains everything I prefer to install on servers I
   use.
2. ``dev.yml``: This contains everything I prefer for local development
   machines. Note that this will begin configuring my editor of choice
   (neovim), and tmux with all the dotfile customizations.
3. ``qtile.yml``: This contains everything I prefer to setup the ``qtile``
   desktop tiling manager.
4. ``servers-lite.yml``: This is replica of the ``servers.yml`` file, but less
   loaded, it doesn't install anything that isn't absolutely necessary.
5. ``pi.yml``: This installs everything for my Raspberry Pis.
6. ``pi-k3s.yml``: This installs everything for my Raspberry Pi 4 K3S Cluster
7. ``pi-clsuterhat.yml``: This installs everything for my Raspberry Pi Zero W
   Cluster Hat, including k3s on it.
8. ``update-hosts.yml``: This updates the ``/etc/hosts`` file on all the machines I
   administer locally at home.
9. ``python-setup.yml``: This sets up Python on a machine, using the deadsnakes
   ppa on Ubuntu, and manually installing every known version of Python >=3.7.
   On Arch, it downloads and *builds* all the required python versions.
