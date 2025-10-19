# Distributed Dotfiles

Ansible-based automation for setting up consistent development environments on **Ubuntu/Debian** and **macOS**.

## Quick Start

### Ubuntu/Debian

```bash
# Base development environment (ALL systems)
ansible-playbook --ask-become-pass playbooks/base-environment.yml

# GUI workstation (includes base + desktop)
ansible-playbook --ask-become-pass playbooks/gui-environment.yml
```

### macOS

```bash
# Base development environment (ALL systems)
ansible-playbook playbooks/macos-base-environment.yml

# GUI workstation (includes base + GUI apps)
ansible-playbook playbooks/macos-gui-environment.yml
```

**Note:** macOS playbooks use Homebrew and don't require `--ask-become-pass`.

## What Gets Installed

### Base Environment (All Systems)

**Ubuntu/Debian** (`base-environment.yml`):
- Fish shell + dotfiles, mise (Node.js, Python, Go, Rust), Rust toolchain
- CLI tools: ripgrep, fd, fzf, starship, gum, direnv, zoxide, watchexec
- tmux (compiled from source) + oh-my-tmux with powerline separators
- Neovim 0.11.2 + custom configuration
- Docker Engine + Compose

**macOS** (`macos-base-environment.yml`):
- Homebrew (auto-installed), Fish shell + dotfiles
- mise (Node.js, Python, Go, Rust), Rust toolchain
- Same CLI tools via Homebrew
- tmux (via Homebrew) + oh-my-tmux with powerline separators
- Neovim (via Homebrew) + custom configuration
- Docker Desktop

### GUI Environment

**Ubuntu/Debian** (`gui-environment.yml`):
- Everything from base +
- Qtile window manager, JetBrains Mono Nerd Font
- Alacritty terminal, Desktop integration

**macOS** (`macos-gui-environment.yml`):
- Everything from base +
- JetBrains Mono Nerd Font, Ghostty terminal
- AeroSpace window manager (i3/sway-like)

## Setup

### Ubuntu/Debian

```bash
sudo apt-get install ansible
```

Create an [ansible inventory](https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html) file:

```bash
cp inventory/hosts.yml inventory/my-home.yml
# Edit with your SSH hostnames

# Set environment variable (optional)
export ANSIBLE_INVENTORY=inventory/my-home.yml

# Or use -i flag
ansible-playbook -i inventory/my-home.yml --ask-become-pass playbooks/base-environment.yml
```

### macOS

```bash
# Install Ansible
python3 -m pip install --user ansible

# Install community modules
ansible-galaxy collection install community.general

# Run playbooks (no inventory needed for localhost)
ansible-playbook playbooks/macos-base-environment.yml
```

## Advanced Usage

### Run specific roles only

```bash
# Using tags
ansible-playbook playbooks/base-environment.yml --tags tmux

# Run oh-my-tmux configuration without sudo
ansible-playbook playbooks/macos-base-environment.yml --tags oh-my-tmux
```

### Target specific hosts (Ubuntu/Debian)

```bash
# Single host
ansible-playbook -i inventory/my-home.yml --ask-become-pass playbooks/base-environment.yml --limit desktop

# Multiple hosts
ansible-playbook -i inventory/my-home.yml --ask-become-pass playbooks/base-environment.yml --limit "desktop,laptop"

# Host groups
ansible-playbook -i inventory/my-home.yml --ask-become-pass playbooks/base-environment.yml --limit servers
```

### Test connectivity

```bash
# With ANSIBLE_INVENTORY set
ansible all -m ping

# With -i flag
ansible -i inventory/my-home.yml all -m ping
```

### List available operations

```bash
# List all tags
ansible-playbook playbooks/base-environment.yml --list-tags

# List all tasks
ansible-playbook playbooks/base-environment.yml --list-tasks
```

## Architecture

**Consolidated role-based structure** with cross-platform support:

- All roles support both Ubuntu/Debian (via apt) and macOS (via Homebrew)
- Conditional task files: `main.yml` (Linux) and `darwin.yml` (macOS)
- Single source of truth for all environment automation
- No external ansible configurations required

**Key roles:**
- Shell: `fish-shell`, `fish-config`, `mise-tools`, `rust-toolchain`
- CLI: `system-deps`, `cli-tools`, `dev-folders`
- Development: `tmux`, `neovim-latest`, `nvim-config`, `tree-sitter-cli`, `docker`
- GUI (Linux): `qtile-wm`, `alacritty`, `desktop-integration`
- GUI (macOS): `ghostty`, `aerospace-wm`, `nerd-fonts`

See `CLAUDE.md` for detailed documentation.

## Testing

Use Vagrant for local testing (Ubuntu/Debian only):

```bash
# Install dependencies
sudo apt-get install sshpass vagrant virtualbox

# Start test VMs
vagrant up

# Test playbooks
ansible-playbook playbooks/base-environment.yml

# Cleanup
vagrant destroy -f
ssh-keygen -R "192.168.60.2"
ssh-keygen -R "192.168.60.3"
ssh-keygen -R "192.168.60.4"
```

**Note:** Vagrant testing is Linux-only. Test macOS playbooks on actual macOS systems.

## Why This Exists

I want **replicable, testable, and idempotent** development environments across all my machines. This repository gives me:

- One command setup for any Ubuntu/Debian server or macOS system
- Consistent tool configurations everywhere
- Living documentation of my development setup

The dotfiles themselves live in separate repositories—this repo manages the **installation and setup** of tools, not the tool configurations.
