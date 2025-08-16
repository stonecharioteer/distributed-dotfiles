# Development Environment Automation - Architecture Gameplan

## Current State Analysis

### Legacy Structure (to be replaced)
- **Location**: `playbooks/tasks/*.yml` 
- **Pattern**: Task-based with `import_tasks` in main playbooks
- **Issues**: Monolithic tasks, no proper variable scoping, limited reusability

### Modern Structure (following qtile pattern)
- **Location**: `~/.config/qtile/ansible/`
- **Pattern**: Role-based with proper Ansible directory structure
- **Benefits**: Modular, reusable, proper variable scoping, handlers, templates

## Role-Based Architecture Design

### Directory Structure
```
roles/
├── base-system/           # System-level dependencies
├── dev-folders/           # Development directory structure  
├── tmux-from-source/      # tmux compilation and installation
├── neovim-latest/         # Neovim binary installation
├── tree-sitter-cli/       # Tree-sitter CLI via npm
├── astronvim-config/      # AstroNvim setup and configuration
└── system-integration/    # Final integration steps
```

### Role Structure (following qtile pattern)
```
role-name/
├── defaults/main.yml      # Default variables
├── files/                 # Static files to copy
├── handlers/main.yml      # Event handlers (restart services, etc.)
├── tasks/main.yml         # Main task list
├── templates/             # Jinja2 templates
└── vars/main.yml          # Role-specific variables
```

## Dependency Management Strategy

### Existing Infrastructure (DO NOT DUPLICATE)
1. **Node.js/npm**: Managed by `~/.config/fish/ansible/roles/dev-tools/` via mise
2. **Rust/Cargo**: Managed by fish ansible roles via mise  
3. **Fonts**: Managed by `~/.config/qtile/ansible/roles/fonts/`
4. **Alacritty**: Managed by qtile ansible roles

### New Role Dependencies
- **tree-sitter-cli**: Depends on Node.js (fish roles)
- **astronvim-config**: Depends on neovim-latest + tree-sitter-cli
- **All roles**: Should follow qtile's variable pattern (`dev_user`, `dev_home`)

## Variable Management

### Standard Variables (following qtile pattern)
```yaml
dev_user: "{{ ansible_user | default('stonecharioteer') }}"
dev_home: "/home/{{ dev_user }}"
```

### Idempotency Patterns
```yaml
- name: Check if tool is already installed
  stat:
    path: "/usr/local/bin/tool"
  register: tool_exists
  
- name: Install tool
  # installation tasks
  when: not tool_exists.stat.exists
```

## Integration Points

### Main Playbooks
- `playbooks/gui.yml`: Include dev roles after existing tasks
- `playbooks/servers.yml`: Include dev roles after existing tasks  
- `playbooks/laptops.yml`: Include dev roles after existing tasks

### New Dedicated Playbook
- `playbooks/dev-environment.yml`: Pure development environment setup

## Implementation Priority

1. **Phase 1**: Infrastructure (GAMEPLAN.md, role structure)
2. **Phase 2**: Core tools (tmux, neovim, tree-sitter) 
3. **Phase 3**: Configuration (astronvim, dev-folders)
4. **Phase 4**: Integration (playbook updates, testing)

## Migration Strategy

1. **Preserve existing**: Keep current task-based system functional
2. **Add roles gradually**: Implement new roles alongside existing tasks
3. **Test thoroughly**: Verify each role works independently 
4. **Eventually deprecate**: Remove old task files after roles are proven

## Quality Standards

### Error Handling
- Use `ignore_errors: yes` for non-critical failures
- Include meaningful error messages and debugging output
- Implement proper cleanup for failed installations

### Documentation
- Clear role README files
- Variable documentation in defaults/main.yml
- Example inventory configurations

### Testing
- Support multiple Ubuntu/Debian versions
- Vagrant-based testing workflow
- Idempotency verification (run twice, same result)