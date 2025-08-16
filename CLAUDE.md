# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is an Ansible-based dotfiles and development environment automation repository for setting up Ubuntu/Debian-based machines with a consistent development environment. The project uses a **hybrid architecture** combining legacy task-based approaches with modern role-based automation.

## Common Commands

### Running Playbooks

**Complete system setup:**
```bash
# For machines with displays (GUI)
ansible-playbook --ask-become-pass playbooks/gui.yml

# For headless development servers
ansible-playbook --ask-become-pass playbooks/servers.yml

# For laptops
ansible-playbook --ask-become-pass playbooks/laptops.yml
```

**Development environment only (NEW):**
```bash
# Pure dev tools without legacy system setup
ansible-playbook --ask-become-pass playbooks/dev-environment.yml
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

### Hybrid Structure (Legacy + Modern)

The repository uses **both** task-based and role-based approaches:

**Legacy Tasks** (`playbooks/tasks/`):
- Preserved for compatibility and system-level setup
- Used for: build dependencies, Docker, Python compilation, Qtile, fonts

**Modern Roles** (`roles/`):
- New approach following qtile ansible pattern
- Used for: development tools (tmux, neovim, astronvim)
- Proper variable scoping, handlers, and modularity

### Main Playbooks

- **playbooks/gui.yml**: Complete GUI setup (legacy tasks + modern roles)
- **playbooks/servers.yml**: Complete server setup (legacy tasks + modern roles)
- **playbooks/laptops.yml**: Complete laptop setup (legacy tasks + modern roles)
- **playbooks/dev-environment.yml**: **NEW** - Pure development environment (roles only)

### Modern Roles (`roles/`)

- **system-deps**: Essential system dependencies and development headers
  - Core system tools (`curl`, `git`, `htop`, `build-essential`)
  - Development libraries (`libssl-dev`, `libffi-dev`, `pkg-config`)
  - Python3 system packages (no compilation dependencies)
  - Build tools (`gcc`, `make`, `cmake`, `autotools`)

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
  - Downloads source, compiles with proper dependencies
  - Installs to `/usr/local/bin/tmux`
  - All required dependencies: `libevent-dev`, `ncurses-dev`, `build-essential`, `bison`, `pkg-config`

- **neovim-latest**: Installs Neovim 0.11.2 binary
  - Downloads from GitHub releases
  - Installs to `/usr/local/bin/nvim`
  - Creates `/usr/local/bin/vim` symlink

- **tree-sitter-cli**: Installs tree-sitter CLI via npm
  - **Dependency**: Requires Node.js from mise (fish ansible setup)
  - Installs globally via npm in mise environment

- **astronvim-config**: Sets up AstroNvim configuration
  - **Dependencies**: neovim-latest, tree-sitter-cli
  - Clones AstroNvim template to `~/.config/nvim`
  - Runs headless plugin installation
  - Installs clipboard dependencies (`xclip`, `wl-clipboard`)

- **docker**: Docker Engine installation with post-install configuration
  - Latest Docker CE, CLI, containerd, buildx, and compose plugins
  - Uses current official installation method (2024)
  - Configures user permissions and service startup
  - Includes all post-installation steps

### Legacy Tasks (Preserved)

Located in `playbooks/tasks/`:
- **build-dependencies.yml**: Core build tools and dependencies
- **dev-tools.yml**: Development velocity tools (starship, ripgrep, fzf, etc.)
- **fish.yml**: Fish shell installation and configuration
- **rust.yml**: Rust toolchain via rustup
- **docker.yml**: Docker installation
- **qtile.yml**: Qtile window manager setup
- **gui-fonts.yml**: Font installation for GUI environments
- **laptop.yml**: Laptop-specific tools (tlp, etc.)
- **python/**: Python compilation and installation tasks

### Dependency Management

**External Dependencies** (handled by separate ansible setups):
- **Node.js/npm**: Managed by `~/.config/fish/ansible/` via mise
- **Rust/Cargo**: Managed by fish ansible via mise
- **Fonts**: Managed by `~/.config/qtile/ansible/roles/fonts/`
- **Fish shell + tools**: Managed by fish ansible setup

**Role Dependencies**:
- `tree-sitter-cli` → requires Node.js (fish setup)
- `astronvim-config` → requires `neovim-latest` + `tree-sitter-cli`
- All roles use standard variables: `dev_user`, `dev_home`

### Key Tools Installed

**Modern (via roles)**:
- **System Dependencies**: Build tools, development headers, Python3 system packages
- **CLI Tools**: ripgrep, fd-find, fzf, starship, gum, direnv, httpie, zoxide, watchexec
- **tmux**: Latest version compiled from source
- **Neovim**: 0.11.2 binary with vim symlink
- **AstroNvim**: Complete configuration with plugin setup
- **tree-sitter CLI**: Via npm for syntax highlighting
- **Docker**: Latest Engine with Compose, proper user setup

**Legacy (via tasks)**:
- **Shell**: Fish with starship prompt
- **Languages**: Python (compiled from source), Rust (via mise)
- **CLI Tools**: ripgrep, fd-find, fzf, exa, bottom, du-dust, tokei, zoxide
- **Window Manager**: Qtile (for GUI machines)
- **Containerization**: Docker

### Configuration Management

- **Modern roles**: Self-contained with proper defaults and handlers
- **Legacy tasks**: Use personal dotfiles repositories via git/symlinks
- **Variable consistency**: All roles use `dev_user`/`dev_home` pattern
- **Idempotency**: Roles check for existing installations before proceeding

### Testing Environment

- Vagrant-based testing with VirtualBox
- Multiple Ubuntu versions supported (18.04, 20.04, 22.04)
- Private network configuration (192.168.60.x)
- Ansible configuration in `ansible.vagrant.cfg` for testing

## Implementation Notes

1. **Role Execution Order**: Roles run after legacy tasks in main playbooks
2. **Error Handling**: Roles include rescue blocks and proper cleanup
3. **Documentation**: See `GAMEPLAN.md` for detailed architecture decisions
4. **Migration**: Legacy tasks preserved for compatibility during transition