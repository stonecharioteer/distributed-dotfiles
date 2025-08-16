# Using SSH Config with Ansible

## Benefits of SSH Config Hostnames

- **Clean inventory**: Just hostnames, no IPs
- **Centralized config**: SSH settings in one place (~/.ssh/config)
- **Easier management**: Change IPs in SSH config, inventory stays the same
- **SSH features**: Jump hosts, port forwarding, key management

## Example SSH Config

Add to `~/.ssh/config`:

```ssh
# Local desktop (if running ansible from different machine)
Host desktop
    HostName 192.168.1.100
    User stonecharioteer
    IdentityFile ~/.ssh/id_ed25519

# Laptop
Host laptop
    HostName 192.168.1.101
    User stonecharioteer
    IdentityFile ~/.ssh/id_ed25519

# Work laptop
Host work-laptop
    HostName 192.168.1.102
    User stonecharioteer
    IdentityFile ~/.ssh/id_ed25519

# Home lab server
Host homelab
    HostName 192.168.1.200
    User stonecharioteer
    Port 22
    IdentityFile ~/.ssh/id_ed25519

# Raspberry Pi
Host pi4
    HostName 192.168.1.201
    User pi
    IdentityFile ~/.ssh/id_ed25519

# NAS
Host nas
    HostName 192.168.1.220
    User admin
    Port 2222
    IdentityFile ~/.ssh/id_ed25519

# Example with jump host (if needed)
Host remote-server
    HostName 10.0.0.100
    User stonecharioteer
    ProxyJump homelab
    IdentityFile ~/.ssh/id_ed25519
```

## Ansible Usage

With SSH config setup, your inventory becomes very clean:

```yaml
all:
  children:
    workstations:
      hosts:
        desktop:
        laptop:
        work-laptop:
    servers:
      hosts:
        homelab:
        pi4:
        nas:
```

Then run:
```bash
# Test connectivity
ansible all -m ping

# Run playbooks
ansible-playbook playbooks/complete-workstation.yml --limit workstations
ansible-playbook playbooks/server-setup.yml --limit servers
```

## Pro Tips

1. **Use meaningful hostnames** that match your mental model
2. **Group similar machines** in SSH config with comments
3. **Set common options** at the top with `Host *`
4. **Use IdentitiesOnly yes** to avoid key confusion
5. **Test SSH first**: `ssh hostname` should work before running ansible