# Distributed Dotfiles

## Why

I'm very particular about my tools. I want a great development environment that *I* control. This repository gives me replicable configurations for my tooling. The dotfiles themselves are *separate* from this repository. I'm not keeping any configurations here for my tools, besides the *choice* of the dotfiles and tools. With this repo, I'd like setting up any server with a simple ansible playbook run. That way, I have the exact same configuration *everywhere*.

I've seen other developers maintain dotfile repositories, but I'm not very happy with *how* they use them. Installing the tools is half the trouble, and ansible solves them perfectly in my opinion.

## Objectives

* One command setup of any server I use with all the tools and configurations I prefer.
* Replicable, *testable* and **idempotent** configurations that I can run on any server and/or laptop.
* Continuously living configuration which I can use to remember how I set up my development machines.

## Modern Development Environment

This repository now features a **modern role-based architecture** that installs:

### Core Development Tools

* **Editor** - Neovim 0.11.2 with [AstroNvim](https://github.com/AstroNvim/AstroNvim) configuration
* **Terminal Multiplexer** - tmux (latest version, compiled from source)
* **Development Structure** - Standardized folder layout (`~/code/`, `~/workspace/`)
* **Language Support** - tree-sitter CLI for advanced syntax highlighting

### Additional Tools (Legacy Tasks)

* **Programming Languages** - Python (self-compiled), Rust (via mise)
* **CLI Tools** - `ripgrep`, `fd-find`, `tokei`, `bat`, `exa`, `zoxide`, `fzf`
* **Shell** - `fish` with modern integrations
* **Window Manager** - Qtile (for GUI machines)

## Setup

**NOTE** - This configuration is currently only valid for Debian-based / Ubuntu-based machines.

Install ansible and other dependencies on the host machine.

```bash
sudo apt-get install ansible
```

Create an [ansible inventory](https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html) file, and follow the instructions in the official documentation to use it.

## Usage

**NOTE:** Ensure you set `ANSIBLE_INVENTORY` before running any of these, or use the `-i` parameter to provide the path to it.

### Recommended: Modern Development Environment Setup

```bash
ansible-playbook --ask-become-pass playbooks/dev-environment.yml
```

This installs the core development tools using the modern role-based architecture:

* System dependencies (build tools, development headers, Python3)
* Modern CLI tools (ripgrep, fd-find, fzf, starship, gum, direnv, watchexec)
* Development folder structure (`~/code/`, `~/workspace/`)
* tmux compiled from latest source
* Neovim 0.11.2 with vim symlink
* tree-sitter CLI (requires Node.js via mise)
* AstroNvim configuration with plugin setup
* Docker Engine with complete post-install setup

### Prerequisites

The development environment playbook requires Node.js to be installed via mise. Run the fish shell ansible setup first if you need Node.js/mise:

```bash
# Setup fish shell with mise (Node.js, Python, Go, Rust)
cd ~/.config/fish/ansible
ansible-playbook fish-setup.yml
```

### Legacy Complete System Setup (Includes GUI/System Tools)

```bash
# For machines with displays (includes Qtile, fonts, system tools)
ansible-playbook --ask-become-pass playbooks/gui.yml 

# For headless development servers (includes Docker, system setup)
ansible-playbook --ask-become-pass playbooks/servers.yml 

# For laptops (includes Qtile, fonts, laptop-specific tools)
ansible-playbook --ask-become-pass playbooks/laptops.yml
```

### Ansible Tag Operations

Run only specific components:

```bash
ansible-playbook --ask-become-pass playbooks/gui.yml --tags docker
```

Skip certain components:

```bash
ansible-playbook --ask-become-pass playbooks/gui.yml --skip-tags "qtile,docker"
```

List available tags:

```bash
ansible-playbook playbooks/servers.yml --list-tags
```

List all tasks and roles:

```bash
ansible-playbook playbooks/servers.yml --list-tasks
```

## Architecture

This repository uses a **hybrid architecture**:

### Modern Roles (`roles/`)
- Used for core development tools (tmux, neovim, astronvim)
- Proper Ansible role structure with variables, handlers, and templates
- Idempotent and self-contained

### Legacy Tasks (`playbooks/tasks/`)
- Preserved for system-level setup (build tools, Docker, Qtile, fonts)
- Will be gradually migrated to roles over time

For detailed architecture information, see `CLAUDE.md` and `GAMEPLAN.md`.

## Testing

If you want to test the playbooks locally first, then install Virtualbox and Vagrant.

```bash
sudo apt-get install sshpass vagrant virtualbox
```

I've included the hosts file and the `ansible.cfg` file so that you can use them with it.

**Note that I'm using `192.168.60.*` for the private network, so if your network uses it, be sure to select something else!**

Then, run `vagrant up` to bring up the virtual machines. Next, run the following ansible command.

```bash
ansible-playbook playbooks/dev-environment.yml
```

You can test any of the playbooks, but `dev-environment.yml` is the most focused. Once you're done testing, or if you want to get rid of the machines, run the following command.

```bash
vagrant destroy -f
```

**Remember to remove the entries from your `known_hosts` files.** If you've used my values, you can run the following.

```bash
ssh-keygen -R "192.168.60.2"
ssh-keygen -R "192.168.60.3"
ssh-keygen -R "192.168.60.4"
```

Note that I prefer either Ubuntu or Manjaro/Archlinux for my development machines, and mostly Ubuntu for my servers. My playbooks should reflect this. If you'd like to add additional OSes, you should also add to the Vagrantfile and associated files for easier testing. Additionally, testing ARM machines using Vagrant won't be possible. It might be better to spin up Raspbian using docker and then try the ansible files. However, since Raspbian uses Debian underneath, it might be easier to account for those packages which are Debian specific.

When doing this sort of testing repeatedly, you might want to use the `--flush-cache` flag for the ansible commands.

## Dependencies

### Modern Development Environment Dependencies

The new `dev-environment.yml` playbook depends on external tools managed by separate ansible setups:

* **Node.js/npm** - Required for tree-sitter CLI (install via `~/.config/fish/ansible/`)
* **Fonts** - JetBrains Mono Nerd Font (install via `~/.config/qtile/ansible/`)

### Recommended Setup Order

1. Fish shell setup (provides Node.js via mise): `~/.config/fish/ansible/fish-setup.yml`
2. Development environment: `playbooks/dev-environment.yml`
3. Optional GUI setup: `~/.config/qtile/ansible/qtile-setup.yml`

This modular approach allows you to pick and choose which components you need for different machine types.