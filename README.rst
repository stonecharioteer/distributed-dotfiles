=============================
Distributed Dotfiles
=============================

-----
Why
-----

I'm very particular about my tools. I want a great development environment that
*I* control. This repository gives me replicable configurations for my tooling.
The dotfiles themselves are *separate* from this repository. I'm not keeping any
configurations here for my tools, besides the *choice* of the dotfiles and tools.
With this repo, I'd like setting up any server with a simple ansible playbook run.
That way, I have the exact same configuration *everywhere*.

I've seen other developers maintain dotfile repositories, but I'm not very
happy with *how* they use them. Installing the tools is half the trouble, and
ansible solves them perfectly in my opinion.

--------------------------
Objectives
--------------------------

* One command setup of any server I use with all the tools and configurations I
  prefer.
* Replicable, *testable* and **idempotent** configurations that I can run on
  any server and/or laptop.
* Continuously living configuration which I can use to remember how I set up my development
  machines.

----------------------
Included Tools
----------------------

* Editor - Neovim with the `AstroNvim <https://github.com/AstroNvim/AstroNvim>`_ configuration
* Programming Languages - Python (self-compiled and user-specific), Rust
* Tooling - ``tmux``, ``ripgrep``, ``fd-find``, ``tokei``, ``bat``, ``exa``, ``zoxide``, ``fzf``
* Shell - ``fish``

------------------
Setup
------------------

**NOTE** - This configuration is currently only valid for Debian-based / Ubuntu-based machines.

Install ansible and other dependencies on the host machine.

.. code:: bash

   sudo apt-get install ansible

Create an `ansible inventory
<https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html>`_
file, and follow the instructions in the official documentation to use it.


Usage
==============

**NOTE:** Ensure you set ``ANSIBLE_INVENTORY`` before running any of these, or
use the ``-i`` parameter to provide the path to it.

To setup a machine that you'd use with displays.

.. code:: bash

   ansible-playbook --ask-become-pass --playbooks/gui.yml 

To setup a headless development server.

.. code:: bash

   ansible-playbook --ask-become-pass --playbooks/servers.yml 

To setup a laptop.

.. code:: bash

   ansible-playbook --ask-become-pass --playbooks/laptops.yml

To run only a specific tag when running a playbook.

.. code:: bash

   ansible-playbook --ask-become-pass --playbooks/gui.yml --tags docker

To ignore certain tags when running a playbook.

.. code:: bash

   ansible-playbook --ask-become-pass --playbooks/gui.yml --skip-tags "qtile,docker"

To list all tags.

.. code:: bash

   ansible-playbook --playbooks/servers.yml --list-tags

To list all tasks.

.. code:: bash

   ansible-playbook --playbooks/servers.yml --list-tasks

To list all tasks that *would* be performed for selected tags.


.. code:: bash

   ansible-playbook --playbooks/gui.yml --tags "qtile,docker" --list-tags


Playbooks
=============


``gui.yml``
--------------

This playbook will setup a machine with Qtile and all my preferred
development tools.

``servers.yml``
-----------------

This playbook will setup a machine with all my preferred development tools.

``laptops.yml``
------------------

This playbook will setup a laptop with qtile and all my preferred development
tools.

Tasks
=============

I've set this repo up so that tasks are separate from the playbooks for 
modularization.

1. ``build-development.yml`` - Installs all the possible build tools.
2. ``dev-tools.yml`` - Installs my development tools
3. ``fish.yml`` - Installs the fish shell.
4. ``gui-fonts.yml`` - Installs fonts I need for tmux and neovim to render as
   expected in a terminal.
5. ``neovim.yml`` - Installs neovim 0.8 and sets up AstroNvim.
6. ``qtile.yml`` - Installs the Qtile tiling window manager and configures it
   using my configuration.
7. ``rust.yml`` - Installs the ``rustup`` tool.
8. ``tmux.yml`` - Installs ``tmux`` and configures it.
9. ``python/3.9.yml`` - Installs Python 3.9 by compiling it from source and
   then saves it to the ``~/.python/python3.9`` folder.
10. ``python/build-dependencies.yml`` - Installs all the required dependencies
    to build python from source.

---------
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

   ansible-playbook playbook/server.yml

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
