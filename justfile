# Distributed Dotfiles - Task Runner

set shell := ["bash", "-cu"]

# Show available tasks
_default:
    just --list

# Run repository quality checks
check:
    pre-commit run --all-files

# Show local setup diagnostics
doctor:
    ./scripts/doctor.sh

# Bootstrap a headless Linux development machine
setup-headless host user="stonecharioteer":
    ./bootstrap headless --host {{ host }} --user {{ user }}

# Bootstrap a Linux GUI workstation with Qtile
setup-gui host user="stonecharioteer":
    ./bootstrap gui --host {{ host }} --user {{ user }}

# Bootstrap the current macOS machine with base development tools
setup-mac:
    ./bootstrap mac

# Bootstrap the current macOS machine with GUI tools
setup-mac-gui:
    ./bootstrap mac-gui

# Dry-run a headless Linux setup
check-headless host user="stonecharioteer":
    ./bootstrap headless --host {{ host }} --user {{ user }} --check --diff

# Dry-run a Linux GUI setup
check-gui host user="stonecharioteer":
    ./bootstrap gui --host {{ host }} --user {{ user }} --check --diff
