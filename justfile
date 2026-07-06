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

# Bootstrap headless inventory targets from inventory/hosts.yml; opens gum selector when target is empty
bootstrap target="":
    #!/usr/bin/env bash
    if [[ -n "{{ target }}" ]]; then
      ./bootstrap headless -i inventory/hosts.yml -- --limit "{{ target }}"
    else
      ./bootstrap headless
    fi

# Common typo alias for bootstrap
boostrap target="":
    just bootstrap "{{ target }}"

# Dry-run headless inventory targets from inventory/hosts.yml; opens gum selector when target is empty
bootstrap-check target="":
    #!/usr/bin/env bash
    if [[ -n "{{ target }}" ]]; then
      ./bootstrap headless -i inventory/hosts.yml --check --diff -- --limit "{{ target }}"
    else
      ./bootstrap headless --check --diff
    fi

# Bootstrap the ThinkPad headless server laptops
setup-thinkpads:
    just bootstrap thinkpads

# Dry-run the ThinkPad headless server laptops
check-thinkpads:
    just bootstrap-check thinkpads

# Bootstrap a headless Linux development machine
setup-headless host user="stonecharioteer":
    ./bootstrap headless --host {{ host }} --user {{ user }}

# Bootstrap a headless Linux laptop/server and enable Tailscale
setup-headless-laptop host user="stonecharioteer":
    ./bootstrap headless --host {{ host }} --user {{ user }} --enable-tailscale

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
