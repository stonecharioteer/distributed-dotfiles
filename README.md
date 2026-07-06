# Distributed Dotfiles

Ansible-based automation for setting up consistent development environments on **Ubuntu/Debian** and **macOS**.

## Quick Start

Run the doctor first to check local prerequisites:

```bash
./scripts/doctor.sh
# or
just doctor
```

Then choose the profile that matches the machine you are setting up:

| Profile        | Bootstrap command                              | Playbook                               | Target            | Includes                                                          |
| -------------- | ---------------------------------------------- | -------------------------------------- | ----------------- | ----------------------------------------------------------------- |
| Headless Linux | `./bootstrap headless --host HOST --user USER` | `playbooks/base-environment.yml`       | servers/dev boxes | Fish, dotfiles, mise, tmux, Neovim, Hugo, Docker                  |
| Linux GUI      | `./bootstrap gui --host HOST --user USER`      | `playbooks/gui-environment.yml`        | desktops/laptops  | base tools + Qtile, Nerd Font, Alacritty, desktop integration     |
| macOS Base     | `./bootstrap mac`                              | `playbooks/macos-base-environment.yml` | MacBooks          | Homebrew, Fish, dotfiles, dev tools, tmux, Neovim, Docker Desktop |
| macOS GUI      | `./bootstrap mac-gui`                          | `playbooks/macos-gui-environment.yml`  | MacBooks          | macOS base + Ghostty, AeroSpace, Nerd Font                        |

Examples:

```bash
# Base development environment on a Linux host
./bootstrap headless --host 1990-dev --user stonecharioteer

# Linux GUI workstation with Qtile
./bootstrap gui --host desktop --user stonecharioteer

# Current macOS machine
./bootstrap mac
./bootstrap mac-gui
```

The bootstrap script prints the exact `ansible-playbook` command before running it and supports `--check`, `--diff`, `--tags`, `--skip-tags`, `--inventory`, and extra `ansible-playbook` arguments after `--`.

## What Gets Installed

### Base Environment (All Systems)

**Ubuntu/Debian** (`base-environment.yml`):

- Fish shell + dotfiles, mise (Node.js, Python, Go, Rust), Rust toolchain
- CLI tools: ripgrep, fd, fzf, starship, gum, direnv, zoxide, watchexec
- tmux (compiled from source) + oh-my-tmux with powerline separators
- Neovim 0.11.2 + custom configuration
- Hugo Extended 0.146.7 (static site generator)
- Docker Engine + Compose

**macOS** (`macos-base-environment.yml`):

- Homebrew (auto-installed), Fish shell + dotfiles
- mise (Node.js, Python, Go, Rust), Rust toolchain
- Same CLI tools via Homebrew
- tmux (via Homebrew) + oh-my-tmux with powerline separators
- Neovim (via Homebrew) + custom configuration
- Hugo Extended (static site generator)
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

Create an [ansible inventory](https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html) file from the profile-specific examples:

```bash
# Headless Linux servers/dev boxes
cp inventory/headless.example.yml inventory/my-headless.yml

# Linux GUI desktops/laptops
cp inventory/gui.example.yml inventory/my-gui.yml

# Edit with your SSH hostnames, users, and feature flags
```

Recommended inventory model:

- keep one example inventory per machine profile (`headless`, `gui`, `mac`)
- group real hosts by profile (`headless_machines`, `gui_machines`, `macbooks`)
- keep shared defaults in `all.vars`
- keep host-specific overrides in `inventory/host_vars/<host>.yml`
- use feature flags in inventory to opt out of large components like Docker, Hugo, Qtile, Ghostty, or AeroSpace

Then run with either bootstrap or Ansible directly:

```bash
./bootstrap headless -i inventory/my-headless.yml
ansible-playbook -i inventory/my-headless.yml --ask-become-pass playbooks/base-environment.yml
```

### macOS

```bash
# Install Ansible
python3 -m pip install --user ansible

# Install community modules
ansible-galaxy collection install community.general

# Run through bootstrap against localhost
./bootstrap mac
```

## Feature Flags

The main playbooks expose coarse feature flags so inventories can opt out of large components without needing long tag lists:

```yaml
all:
  vars:
    enable_shell_environment: true
    enable_development_tools: true
    enable_docker: true
    enable_hugo: true
    enable_gui_environment: true
    enable_qtile: true
    enable_ghostty: true
    enable_aerospace: true
```

See `inventory/headless.example.yml`, `inventory/gui.example.yml`, and `inventory/mac.example.yml` for profile-specific defaults.

## Development Checks

This repository uses [pre-commit](https://pre-commit.com/) for commit-message hygiene and Ansible/YAML checks.

```bash
# Install hooks, including the commit-msg hook that blocks AI attribution footers
pre-commit install

# Run every configured check manually
pre-commit run --all-files
```

The commit-msg hooks enforce Conventional Commits and block generated attribution such as `Co-authored-by: Claude ...` and `Generated with Claude Code` before it reaches GitHub. GitHub Actions runs matching quality checks on every pull request to `main`, and `main` is protected by required status checks for commit messages, file hygiene, YAML, Ansible, and shell scripts.

## Advanced Usage

### Run specific components using tags

All playbooks support granular control through tags:

#### Linux (Ubuntu/Debian)

```bash
# Install only shell environment
ansible-playbook --ask-become-pass playbooks/base-environment.yml --tags shell

# Install only development tools (skip shell)
ansible-playbook --ask-become-pass playbooks/base-environment.yml --tags dev

# Install specific tools
ansible-playbook --ask-become-pass playbooks/base-environment.yml --tags fish
ansible-playbook --ask-become-pass playbooks/base-environment.yml --tags neovim
ansible-playbook --ask-become-pass playbooks/base-environment.yml --tags docker

# Install GUI only (skip base environment)
ansible-playbook --ask-become-pass playbooks/gui-environment.yml --tags gui

# Install specific GUI components
ansible-playbook --ask-become-pass playbooks/gui-environment.yml --tags qtile
ansible-playbook --ask-become-pass playbooks/gui-environment.yml --tags alacritty

# Skip specific components
ansible-playbook --ask-become-pass playbooks/base-environment.yml --skip-tags docker

# Multiple tags
ansible-playbook --ask-become-pass playbooks/base-environment.yml --tags "fish,tmux,neovim"
```

**Available Linux tags:**

- **Shell:** `shell`, `fish`, `dotfiles`, `scripts`, `mise`, `rust`, `languages`, `config`
- **Development:** `dev`, `deps`, `cli`, `folders`, `tmux`, `neovim`, `editor`, `hugo`, `blog`, `docker`, `containers`
- **GUI:** `gui`, `system`, `locale`, `repos`, `wm`, `qtile`, `fonts`, `terminal`, `alacritty`, `desktop`, `integration`

#### macOS

```bash
# Install only shell environment
ansible-playbook playbooks/macos-base-environment.yml --tags shell

# Install only development tools (skip shell)
ansible-playbook playbooks/macos-base-environment.yml --tags dev

# Install specific tools
ansible-playbook playbooks/macos-base-environment.yml --tags fish
ansible-playbook playbooks/macos-base-environment.yml --tags neovim
ansible-playbook playbooks/macos-base-environment.yml --tags docker

# Install GUI only (skip base environment)
ansible-playbook playbooks/macos-gui-environment.yml --tags gui

# Install specific GUI components
ansible-playbook playbooks/macos-gui-environment.yml --tags ghostty
ansible-playbook playbooks/macos-gui-environment.yml --tags aerospace

# Skip specific components
ansible-playbook playbooks/macos-base-environment.yml --skip-tags docker

# Multiple tags
ansible-playbook playbooks/macos-base-environment.yml --tags "fish,tmux,neovim"
```

**Available macOS tags:**

- **Shell:** `shell`, `fish`, `dotfiles`, `scripts`, `mise`, `rust`, `languages`, `config`
- **Development:** `dev`, `cli`, `folders`, `tmux`, `neovim`, `editor`, `hugo`, `blog`, `docker`, `containers`
- **GUI:** `gui`, `fonts`, `terminal`, `ghostty`, `wm`, `aerospace`

### Target specific hosts (Ubuntu/Debian)

```bash
# Single host
ansible-playbook -i inventory/my-home.yml --ask-become-pass playbooks/base-environment.yml --limit desktop

# Multiple hosts
ansible-playbook -i inventory/my-home.yml --ask-become-pass playbooks/base-environment.yml --limit "desktop,laptop"

# Host groups
ansible-playbook -i inventory/my-home.yml --ask-become-pass playbooks/base-environment.yml --limit servers
```

### Optional Supabase tooling

Supabase tooling is intentionally separate from the base environment. Add hosts
to the `supabase_machines` inventory group, then run:

```bash
ansible-playbook -i inventory/hosts.yml --ask-become-pass playbooks/supabase-tooling.yml
```

The current inventory applies this to `1990-dev`.

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
- Development: `tmux`, `neovim-latest`, `nvim-config`, `tree-sitter-cli`, `hugo`, `docker`
- Optional tooling: `supabase-tooling`
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
