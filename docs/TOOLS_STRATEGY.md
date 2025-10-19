# Tool Installation Strategy

## Overview

This document explains how tools are installed across different roles to avoid conflicts and ensure consistency.

## Package Manager Priority

### Linux (Ubuntu/Debian)
1. **apt** - System package manager (preferred for stability)
2. **External installers** - For tools not in apt (Starship, Gum)
3. **cargo-binstall** - For Rust tools not available in apt

### macOS
1. **Homebrew** - macOS package manager (preferred for everything available)
2. **cargo-binstall** - For Rust tools not available in Homebrew

## Tool Distribution by Role

### `cli-tools` Role
**Purpose**: Install commonly available CLI tools via package managers

**Linux (apt):**
- ripgrep, fd-find, fzf, zoxide, tree
- direnv, httpie, pgcli
- htop, jq, yq
- cowsay, fortune-mod, lolcat, neofetch

**macOS (Homebrew):**
- ripgrep, fd, fzf, zoxide, tree
- starship (via Homebrew instead of installer)
- direnv, httpie, pgcli, gum
- htop, jq, yq
- cowsay, fortune, lolcat, neofetch

**External Installers (Linux only):**
- Starship (via starship.rs/install.sh)
- Gum (via Charm repository)

**Cargo Tools (both platforms):**
- watchexec-cli (only this one, as it's not commonly in package managers)

### `rust-toolchain` Role
**Purpose**: Install Rust toolchain and Rust-native tools via cargo-binstall

**What it installs (both platforms):**
- rustup, cargo, cargo-binstall

**Essential Rust CLI Tools:**
- bat - Better cat with syntax highlighting
- tokei - Code statistics
- du-dust - Better du
- bottom - Better top/htop
- xh - Better httpie (Rust alternative)
- eza - Better ls (replaces exa)
- procs - Better ps

**Additional Rust Tools:**
- sd - Better sed
- tealdeer - tldr client (quick command help)
- grex - Regex pattern generator
- gitui - Terminal UI for git (Linux only)

### Why This Split?

1. **Stability**: Package managers (apt/Homebrew) provide stability and system integration
2. **Updates**: Package manager tools get updated with system updates
3. **Availability**: Some Rust tools aren't available in package managers
4. **Speed**: cargo-binstall is fast for installing Rust binaries
5. **No Conflicts**: Clear separation prevents duplicate installations

## Tool Categories

### Core Tools (via Package Manager)
These are essential and widely available:
- **Search**: ripgrep, fd
- **Navigation**: zoxide, fzf
- **Shell**: starship (Homebrew on macOS, installer on Linux)

### Extended Rust Tools (via cargo-binstall)
These enhance the terminal experience but may not be in all package managers:
- **File viewing**: bat, eza
- **Monitoring**: bottom, procs, du-dust
- **Utilities**: sd, tealdeer, grex
- **Development**: tokei, xh

### Development Tools (via Package Manager)
These are development-focused:
- **APIs**: httpie
- **Databases**: pgcli
- **Data**: jq, yq
- **Environment**: direnv

### System Tools
- **htop**: Process viewer (traditional)
- **btop**: Modern system resource monitor (C++, better than htop)
- **tree**: Directory visualization

## Installation Flow

### Linux
```
1. cli-tools (apt) → ripgrep, fd, zoxide, starship (external), fzf, etc.
2. rust-toolchain → rustup, cargo
3. rust-toolchain (cargo) → bat, eza, tokei, bottom, etc.
```

### macOS
```
1. cli-tools (Homebrew) → ripgrep, fd, zoxide, starship, fzf, etc.
2. rust-toolchain → rustup, cargo
3. rust-toolchain (cargo) → bat, eza, tokei, bottom, etc.
```

## Tool Reference

### Installed via cli-tools (Package Manager)

| Tool | Linux | macOS | Purpose |
|------|-------|-------|---------|
| ripgrep | ✓ | ✓ | Fast text search |
| fd | ✓ | ✓ | Fast file search |
| fzf | ✓ | ✓ | Fuzzy finder |
| zoxide | ✓ | ✓ | Smart directory navigation |
| starship | External | ✓ | Modern prompt |
| direnv | ✓ | ✓ | Environment management |
| httpie | ✓ | ✓ | HTTP client |
| pgcli | ✓ | ✓ | PostgreSQL client |
| jq | ✓ | ✓ | JSON processor |
| yq | ✓ | ✓ | YAML processor |
| gum | External | ✓ | Terminal UI |
| htop | ✓ | ✓ | Process viewer |
| btop | ✓ | ✓ | Modern system monitor |
| tree | ✓ | ✓ | Directory tree |
| cowsay | ✓ | ✓ | ASCII art |
| fortune | ✓ | ✓ | Random quotes |
| lolcat | ✓ | ✓ | Colorful output |
| neofetch | ✓ | ✓ | System info |

### Installed via rust-toolchain (cargo-binstall)

| Tool | Both | Purpose |
|------|------|---------|
| bat | ✓ | Better cat with syntax highlighting |
| eza | ✓ | Better ls (modern, colorful) |
| tokei | ✓ | Code line counter & statistics |
| bottom | ✓ | Better top/htop (btm command) |
| du-dust | ✓ | Better du (dust command) |
| procs | ✓ | Better ps (process viewer) |
| xh | ✓ | Better httpie (Rust alternative) |
| sd | ✓ | Better sed (stream editor) |
| tealdeer | ✓ | tldr client (quick help) |
| grex | ✓ | Regex pattern generator |
| gitui | ✓ (Linux) | Terminal UI for git |

## Verification

After installation, verify tools:

```bash
# Core tools (from cli-tools)
rg --version        # ripgrep
fd --version        # fd-find
fzf --version       # fuzzy finder
zoxide --version    # smart cd
starship --version  # prompt
jq --version        # JSON processor
yq --version        # YAML processor
btop --version      # system monitor

# Rust tools (from rust-toolchain)
bat --version       # better cat
eza --version       # better ls
tokei --version     # code stats
btm --version       # bottom (better top)
dust --version      # better du
procs --version     # better ps
xh --version        # http client
sd --version        # better sed
tldr --version      # tealdeer
```

## Adding New Tools

### To add a tool via package manager (cli-tools):
1. Check if available in apt (Ubuntu) and Homebrew (macOS)
2. Add to `cli_packages` in `roles/cli-tools/defaults/main.yml`
3. Add to Homebrew list in `roles/cli-tools/tasks/darwin.yml`

### To add a tool via cargo (rust-toolchain):
1. Check if available on crates.io and cargo-binstall
2. Add to appropriate list in `roles/rust-toolchain/tasks/main.yml` (Linux)
3. Add to appropriate list in `roles/rust-toolchain/tasks/darwin.yml` (macOS)

## Troubleshooting

### Tool not found after installation
- Linux: Check `~/.cargo/bin` is in PATH
- macOS: Check `/opt/homebrew/bin` is in PATH
- Restart shell: `exec fish` or `exec bash`

### Duplicate installations
- This strategy prevents duplicates by using package managers for core tools
- Rust-specific enhancements go via cargo
- No tool should be installed in both roles

### Update tools
- **Linux**: `sudo apt update && sudo apt upgrade` + `rustup update && cargo install-update -a`
- **macOS**: `brew update && brew upgrade` + `rustup update && cargo install-update -a`
