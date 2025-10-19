# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is an Ansible-based dotfiles and development environment automation repository for setting up **Ubuntu/Debian-based machines** and **macOS** with a consistent development environment. The project uses a **consolidated role-based architecture** that brings together all environment automation into a single repository.

## Common Commands

### Running Playbooks

**Ubuntu/Debian (Simple 2-playbook setup):**
```bash
# Base development environment (for ALL systems)
ansible-playbook --ask-become-pass playbooks/base-environment.yml

# GUI workstation (includes base + desktop environment)
ansible-playbook --ask-become-pass playbooks/gui-environment.yml
```

**macOS (Simple 2-playbook setup):**
```bash
# Base development environment (for ALL macOS systems)
ansible-playbook playbooks/macos-base-environment.yml

# GUI workstation (includes base + GUI applications)
ansible-playbook playbooks/macos-gui-environment.yml
```

Note: macOS playbooks use Homebrew and don't require `--ask-become-pass` for most operations.

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

**Ubuntu/Debian:**
- **playbooks/base-environment.yml**: Complete development environment for ALL Ubuntu/Debian systems
  - Fish shell + dotfiles, mise + languages, development tools, tmux, neovim, docker
- **playbooks/gui-environment.yml**: Complete GUI workstation (includes base + desktop)
  - Everything from base-environment.yml + Qtile + fonts + Alacritty + desktop integration

**macOS:**
- **playbooks/macos-base-environment.yml**: Complete development environment for ALL macOS systems
  - Fish shell + dotfiles, mise + languages, development tools, tmux (Homebrew), neovim (Homebrew), docker
- **playbooks/macos-gui-environment.yml**: Complete GUI workstation (includes base + GUI apps)
  - Everything from macos-base-environment.yml + JetBrains Mono Nerd Font + Ghostty + AeroSpace WM

### Legacy Playbooks (DEPRECATED)
- All other playbooks replaced by the simple 2-playbook approach per platform

### Consolidated Roles (`roles/`)

**Platform Support:**
- All roles support Ubuntu/Debian via package managers (apt)
- macOS support via Homebrew (roles include `darwin.yml` task files)
- Conditional includes based on `ansible_os_family`

**Shell Environment:**
- **fish-shell**: Fish shell installation and setup (apt/Homebrew)
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

- **tmux**: Compiles tmux from latest GitHub release (Linux) or installs via Homebrew (macOS)
  - Includes oh-my-tmux configuration with mouse mode and vi key bindings enabled
  - Clones https://github.com/gpakosz/.tmux to ~/.tmux/
  - Creates ~/.tmux.conf symlink and ~/.tmux.conf.local with sensible defaults
  - Enables powerline separators (requires Nerd Fonts for proper display)
- **neovim-latest**: Installs Neovim 0.11.2 binary with vim symlink (Linux) or via Homebrew (macOS)
- **tree-sitter-cli**: Installs tree-sitter CLI via npm (uses mise Node.js)
- **nvim-config**: Sets up custom Neovim configuration with plugins
- **docker**: Docker Engine installation (Linux) or Docker Desktop via Homebrew (macOS)

**GUI Environment (Linux):**
- **locale-setup**: System locale configuration
- **base-system**: Essential system packages
- **qtile-wm**: Qtile window manager installation + Adwaita cursor theme
- **alacritty**: Alacritty terminal emulator
- **desktop-integration**: Desktop session management + dark mode preference + cursor configuration

**GUI Environment (macOS):**
- **nerd-fonts**: JetBrains Mono Nerd Font installation (via Homebrew cask)
- **ghostty**: Ghostty terminal emulator (GPU-accelerated, native macOS)
  - Config stored in `roles/ghostty/files/config`
  - Installed to `~/.config/ghostty/config`
  - Features: Rose Pine theme, shell integration, vim-style navigation
  - Uses JetBrains Mono Nerd Font for icon support
- **aerospace-wm**: AeroSpace tiling window manager (macOS-native)

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
- **tmux**: Latest version compiled from source (Linux) or via Homebrew (macOS)
- **Neovim**: 0.11.2 binary with vim symlink (Linux) or via Homebrew (macOS)
- **Custom Neovim config**: Complete configuration with plugin setup
- **tree-sitter CLI**: Via npm for syntax highlighting
- **Docker**: Latest Engine with Compose (Linux) or Docker Desktop (macOS)

**GUI Environment (Linux)**:
- **Qtile**: Modern tiling window manager
- **JetBrains Mono Nerd Font**: Programming font with icons
- **Alacritty**: GPU-accelerated terminal emulator
- **Desktop Integration**: Session management, launchers, dark mode preference, cursor configuration
- **Adwaita Cursor Theme**: 16px cursor theme for high-DPI displays

**GUI Environment (macOS)**:
- **JetBrains Mono Nerd Font**: Programming font with icons (via Homebrew)
- **Ghostty**: GPU-accelerated terminal emulator (native macOS)
- **AeroSpace**: Tiling window manager (native macOS, i3/sway-like keybindings)

### Configuration Management

- **Consolidated roles**: All self-contained with proper defaults and handlers
- **Cross-platform support**: Roles include both Linux (main.yml) and macOS (darwin.yml) task files
- **Package managers**: apt (Ubuntu/Debian), Homebrew (macOS)
- **Variable consistency**: All roles use `dev_user`/`dev_home` pattern
  - Linux: `dev_home: "/home/{{ dev_user }}"`
  - macOS: `dev_home: "{{ ansible_env.HOME }}"`
- **Idempotency**: Roles check for existing installations before proceeding
- **Single source of truth**: No external ansible configurations required

### Testing Environment

- Vagrant-based testing with VirtualBox
- Multiple Ubuntu versions supported (18.04, 20.04, 22.04)
- Private network configuration (192.168.60.x)
- Ansible configuration in `ansible.vagrant.cfg` for testing

## Implementation Notes

1. **Consolidated Architecture**: All functionality now uses role-based approach
2. **Cross-Platform Support**:
   - Roles detect OS via `ansible_os_family` (Darwin for macOS, Debian for Ubuntu)
   - Platform-specific tasks in separate files (main.yml for Linux, darwin.yml for macOS)
   - Homebrew automatically installed on macOS if not present
3. **Error Handling**: Roles include rescue blocks and proper cleanup
4. **Documentation**: See `GAMEPLAN.md` for detailed architecture decisions
5. **SSH Config Integration**: Uses SSH hostnames for clean inventory management
6. **Modular Playbooks**: Choose components based on system type and needs
7. **mise Usage**: Only for Node.js and Go environments (`node@latest` and `go@latest` as global installs)
8. **Platform-Specific Features**:
   - Linux: Desktop integration with gsettings, Adwaita cursor theme (16px), Qtile WM
   - macOS: AeroSpace WM, Ghostty terminal, native Homebrew integration
9. **Build Tools**:
   - Linux: Compile tmux and Neovim from source for latest versions
   - macOS: Use Homebrew for tmux and Neovim (simpler, maintained by Homebrew)