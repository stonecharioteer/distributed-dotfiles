# Distributed Dotfiles - Task Runner

# Setup a headless Linux server
setup-linux-server host user:
    ansible-playbook --ask-become-pass -i {{ host }}, -u {{ user }} playbooks/base-environment.yml
