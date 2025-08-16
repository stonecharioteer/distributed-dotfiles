# Distributed Dotfiles

## TLDR - Quick Commands

**Set up your inventory once:**
```bash
# Copy and customize the inventory template
cp inventory/hosts.yml inventory/my-home.yml
# Edit inventory/my-home.yml with your SSH hostnames
```

**Run on all systems (using environment variable):**
```bash
# Set environment variable (one time)
export ANSIBLE_INVENTORY=inventory/my-home.yml

# Base development environment (servers, workstations, laptops)
ansible-playbook --ask-become-pass playbooks/base-environment.yml

# GUI workstation (includes base + desktop)
ansible-playbook --ask-become-pass playbooks/gui-environment.yml
```

**Or use -i flag each time:**
```bash
# Base development environment
ansible-playbook -i inventory/my-home.yml --ask-become-pass playbooks/base-environment.yml

# GUI workstation
ansible-playbook -i inventory/my-home.yml --ask-become-pass playbooks/gui-environment.yml
```

**Run on specific hosts:**
```bash
# Single machine by hostname
ansible-playbook -i inventory/my-home.yml --ask-become-pass playbooks/base-environment.yml --limit desktop
ansible-playbook -i inventory/my-home.yml --ask-become-pass playbooks/gui-environment.yml --limit laptop

# Group of machines
ansible-playbook -i inventory/my-home.yml --ask-become-pass playbooks/base-environment.yml --limit servers
ansible-playbook -i inventory/my-home.yml --ask-become-pass playbooks/gui-environment.yml --limit workstations

# Multiple specific hosts
ansible-playbook -i inventory/my-home.yml --ask-become-pass playbooks/base-environment.yml --limit "desktop,laptop,homelab"
```

**Test connectivity:**
```bash
# Using environment variable
ansible all -m ping
ansible desktop -m ping

# Using -i flag
ansible -i inventory/my-home.yml all -m ping
ansible -i inventory/my-home.yml desktop -m ping
```

---

## Why

I'm very particular about my tools. I want a great development environment that *I* control. This repository gives me replicable configurations for my tooling. The dotfiles themselves are *separate* from this repository. I'm not keeping any configurations here for my tools, besides the *choice* of the dotfiles and tools. With this repo, I'd like setting up any server with a simple ansible playbook run. That way, I have the exact same configuration *everywhere*.

I've seen other developers maintain dotfile repositories, but I'm not very happy with *how* they use them. Installing the tools is half the trouble, and ansible solves them perfectly in my opinion.

## Objectives

* One command setup of any server I use with all the tools and configurations I prefer.
* Replicable, *testable* and **idempotent** configurations that I can run on any server and/or laptop.
* Continuously living configuration which I can use to remember how I set up my development machines.

## Consolidated Development Environment

This repository features a **consolidated role-based architecture** that provides complete environment setup with modular playbooks for different system types.

### Available Playbooks

Simple 2-playbook structure for all your development needs:

#### 🛠️ Base Development Environment (`base-environment.yml`)
Complete development setup for ALL systems (servers, workstations, laptops):
* **Fish shell** - Modern shell with syntax highlighting + dotfiles repository
* **mise** - Runtime version manager (Node.js, Python, Go, Rust)
* **Rust toolchain** - Enhanced with cargo-binstall
* **Fish configuration** - Cloned from your dotfiles repository
* **System dependencies** - Build tools, development headers
* **Modern CLI tools** - ripgrep, fd, fzf, starship, gum, direnv, watchexec
* **Development structure** - Standardized folder layout
* **tmux** - Latest version compiled from source
* **Neovim + AstroNvim** - Modern editor with full configuration
* **Docker** - Container development platform

```bash
ansible-playbook --ask-become-pass playbooks/base-environment.yml
```

#### 🖥️ GUI Workstation (`gui-environment.yml`)
Complete GUI workstation setup (includes everything from base + GUI):
* **Everything from base-environment.yml** 
* **Qtile** - Modern tiling window manager + dotfiles repository
* **JetBrains Mono Nerd Font** - Programming font with icons
* **Alacritty** - GPU-accelerated terminal emulator
* **Desktop integration** - Session management and launchers

```bash
ansible-playbook --ask-become-pass playbooks/gui-environment.yml
```

## Setup

**NOTE** - This configuration is currently only valid for Debian-based / Ubuntu-based machines.

Install ansible and other dependencies on the host machine.

```bash
sudo apt-get install ansible
```

Create an [ansible inventory](https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html) file, and follow the instructions in the official documentation to use it.

## Usage

**NOTE:** Ensure you set `ANSIBLE_INVENTORY` before running any of these, or use the `-i` parameter to provide the path to it.

### Quick Start

Choose the setup that matches your system:

```bash
# For ALL systems (servers, workstations, laptops)
ansible-playbook --ask-become-pass playbooks/base-environment.yml

# For GUI systems (includes everything from base + desktop environment)  
ansible-playbook --ask-become-pass playbooks/gui-environment.yml
```

**That's it!** Two simple commands for any system type.

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

This repository uses a **consolidated role-based architecture**:

### Consolidated Roles (`roles/`)
All functionality has been consolidated into this repository from external configs:

**Shell Environment:**
- `fish-shell` - Fish shell installation and setup
- `mise-tools` - Runtime version manager (Node.js, Python, Go, Rust)
- `rust-toolchain` - Enhanced Rust toolchain with cargo-binstall
- `fish-config` - Fish configuration and abbreviations

**Development Tools:**
- `system-deps` - System dependencies and development headers
- `cli-tools` - Modern CLI utilities (ripgrep, fd, fzf, starship, etc.)
- `dev-folders` - Standardized development directory structure
- `tmux-from-source` - tmux compiled from latest source
- `neovim-latest` - Neovim binary installation
- `tree-sitter-cli` - Tree-sitter CLI for syntax highlighting
- `astronvim-config` - AstroNvim configuration and plugins
- `docker` - Docker Engine with complete setup

**GUI Environment:**
- `locale-setup` - System locale configuration
- `base-system` - Essential system packages
- `qtile-wm` - Qtile window manager
- `nerd-fonts` - JetBrains Mono Nerd Font installation
- `alacritty` - Alacritty terminal emulator
- `desktop-integration` - Desktop session management

### Modular Playbooks
- **Focused playbooks** for different system types and use cases
- **Dependency management** between components
- **Idempotent and self-contained** role execution

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

All dependencies have been consolidated into this repository. No external ansible setups are required.

### Role Dependencies

The roles have been designed with clear dependency chains:

* **tree-sitter-cli** → requires Node.js (provided by `mise-tools`)
* **astronvim-config** → requires `neovim-latest` + `tree-sitter-cli`
* **Development tools** → require shell environment for proper operation
* **GUI environment** → works independently but complements dev tools

### Setup Order Recommendations

1. **Shell first**: `shell-environment.yml` provides the foundation
2. **Development tools**: `dev-environment.yml` adds coding capabilities  
3. **GUI environment**: `gui-environment.yml` for desktop systems

Or use the consolidated playbooks (`complete-workstation.yml` or `server-setup.yml`) which handle dependency order automatically.