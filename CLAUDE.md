# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is an Ansible-based dotfiles and development environment automation repository for setting up Ubuntu/Debian-based machines with a consistent development environment. The project uses a **consolidated role-based architecture** that brings together all environment automation into a single repository.

## Common Commands

### Running Playbooks

**Simple 2-playbook setup:**
```bash
# Base development environment (for ALL systems)
ansible-playbook --ask-become-pass playbooks/base-environment.yml

# GUI workstation (includes base + desktop environment)
ansible-playbook --ask-become-pass playbooks/gui-environment.yml
```

### Ansible Operations

Run specific tags only:
```bash
ansible-playbook --ask-become-pass playbooks/gui.yml --tags docker
```

Skip certain tags:
```bash
ansible-playbook --ask-become-pass playbooks/gui.yml --skip-tags "qtile,docker"
```

List all available tags:
```bash
ansible-playbook playbooks/servers.yml --list-tags
```

List all tasks and roles:
```bash
ansible-playbook playbooks/servers.yml --list-tasks
```

### Testing with Vagrant

Bring up test VMs:
```bash
vagrant up
```

Test with a specific playbook:
```bash
ansible-playbook playbooks/servers.yml
```

Destroy test VMs:
```bash
vagrant destroy -f
```

Clean SSH known_hosts after testing:
```bash
ssh-keygen -R "192.168.60.2"
ssh-keygen -R "192.168.60.3"
ssh-keygen -R "192.168.60.4"
```

## Architecture

### Consolidated Role-Based Structure

The repository uses a **unified role-based architecture** with all functionality consolidated:

**All Components Now Use Roles** (`roles/`):
- All external configurations migrated into this repository
- Consistent role structure with proper variable scoping, handlers, and modularity
- Single source of truth for all environment automation

### Main Playbooks

- **playbooks/base-environment.yml**: Complete development environment for ALL systems
  - Fish shell + dotfiles, mise + languages, development tools, tmux, neovim, docker
- **playbooks/gui-environment.yml**: Complete GUI workstation (includes base + desktop)
  - Everything from base-environment.yml + Qtile + fonts + Alacritty + desktop integration

### Legacy Playbooks (DEPRECATED)
- All other playbooks replaced by the simple 2-playbook approach

### Consolidated Roles (`roles/`)

**Shell Environment:**
- **fish-shell**: Fish shell installation and setup
- **mise-tools**: Runtime version manager (Node.js, Python, Go, Rust via mise)
- **rust-toolchain**: Enhanced Rust toolchain with cargo-binstall
- **fish-config**: Fish configuration and abbreviations

**Development Tools:**
- **system-deps**: Essential system dependencies and development headers
  - Core system tools (`curl`, `git`, `htop`, `build-essential`)
  - Development libraries (`libssl-dev`, `libffi-dev`, `pkg-config`)
  - Python3 system packages and build tools

- **cli-tools**: Modern CLI development tools
  - File/text search: `ripgrep`, `fd-find`, `fzf`, `tree`
  - Development utilities: `direnv`, `httpie`, `zoxide`
  - File watching: `watchexec-cli` (via cargo binstall)
  - Terminal UI: `starship` prompt, `gum` terminal tools
  - Fun utilities: `cowsay`, `fortune`, `lolcat`, `neofetch`

- **dev-folders**: Creates standardized development directory structure
  - `~/code/checkouts/{personal,work}/`
  - `~/code/tools/`, `~/workspace/{projects,scratch}/`
  - `~/Pictures/screenshots/`, `~/.local/bin/`

- **tmux-from-source**: Compiles tmux from latest GitHub release
- **neovim-latest**: Installs Neovim 0.11.2 binary with vim symlink
- **tree-sitter-cli**: Installs tree-sitter CLI via npm (uses mise Node.js)
- **astronvim-config**: Sets up AstroNvim configuration with plugins
- **docker**: Docker Engine installation with post-install configuration

**GUI Environment:**
- **locale-setup**: System locale configuration
- **base-system**: Essential system packages
- **qtile-wm**: Qtile window manager installation + Adwaita cursor theme
- **nerd-fonts**: JetBrains Mono Nerd Font installation
- **alacritty**: Alacritty terminal emulator
- **desktop-integration**: Desktop session management + dark mode preference + cursor configuration

### Dependency Management

**All Dependencies Consolidated** (no external setups required):
- **Node.js/npm**: Now managed by `mise-tools` role in this repository
- **Rust/Cargo**: Now managed by `rust-toolchain` role in this repository
- **Fonts**: Now managed by `nerd-fonts` role in this repository
- **Fish shell + tools**: Now managed by fish roles in this repository

**Role Dependencies**:
- `tree-sitter-cli` → requires Node.js (provided by `mise-tools`)
- `astronvim-config` → requires `neovim-latest` + `tree-sitter-cli`
- All roles use standard variables: `dev_user`, `dev_home`

### Key Tools Installed

**Shell Environment**:
- **Fish shell**: Modern shell with syntax highlighting
- **mise**: Runtime version manager (Node.js, Python, Go, Rust)
- **Rust toolchain**: Enhanced with cargo-binstall
- **Fish configuration**: Abbreviations and modern integrations

**Development Tools**:
- **System Dependencies**: Build tools, development headers, Python3 system packages
- **CLI Tools**: ripgrep, fd-find, fzf, starship, gum, direnv, httpie, zoxide, watchexec
- **tmux**: Latest version compiled from source
- **Neovim**: 0.11.2 binary with vim symlink
- **AstroNvim**: Complete configuration with plugin setup
- **tree-sitter CLI**: Via npm for syntax highlighting
- **Docker**: Latest Engine with Compose, proper user setup

**GUI Environment**:
- **Qtile**: Modern tiling window manager
- **JetBrains Mono Nerd Font**: Programming font with icons
- **Alacritty**: GPU-accelerated terminal emulator
- **Desktop Integration**: Session management, launchers, dark mode preference, cursor configuration
- **Adwaita Cursor Theme**: 16px cursor theme for high-DPI displays

### Configuration Management

- **Consolidated roles**: All self-contained with proper defaults and handlers
- **Variable consistency**: All roles use `dev_user`/`dev_home` pattern
- **Idempotency**: Roles check for existing installations before proceeding
- **Single source of truth**: No external ansible configurations required

### Testing Environment

- Vagrant-based testing with VirtualBox
- Multiple Ubuntu versions supported (18.04, 20.04, 22.04)
- Private network configuration (192.168.60.x)
- Ansible configuration in `ansible.vagrant.cfg` for testing

## Implementation Notes

1. **Consolidated Architecture**: All functionality now uses role-based approach
2. **Error Handling**: Roles include rescue blocks and proper cleanup
3. **Documentation**: See `GAMEPLAN.md` for detailed architecture decisions
4. **SSH Config Integration**: Uses SSH hostnames for clean inventory management
5. **Modular Playbooks**: Choose components based on system type and needs
- You must not use mise to install anything else. It's only to install node and go environments, and I use `node@latest` and `go@latest` as my global installs via mise.
- The desktop-integration role sets browser dark mode preference via `gsettings` and configures 16px Adwaita cursor theme for high-DPI displays.