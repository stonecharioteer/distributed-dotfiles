# Pi configuration

This role installs Pi with mise-managed Node.js and shares the reusable parts
of the controller's Pi setup. It runs in all four base/GUI playbooks after mise
and Herdr. Set `enable_pi: false` to skip it.

## Shared settings and extensions

- Pi 0.85.1, `openai-codex/gpt-5.6-sol`, high thinking, hidden thinking blocks,
  and the dark theme.
- Global Simplified Technical English instructions in a managed `AGENTS.md` block.
- `pi-codex-goal` 0.2.0: explicit goals and completion tracking.
- `pi-env-guard` 1.1.1: environment-file validation and leak checks.
- `pi-vision-handoff` 0.10.1: image descriptions for text-only models.
- `pi-powerline-footer` 0.18.0: status display, prompt stash, and queue controls.
- `pi-xai-oauth` 1.6.0: xAI login and optional xAI tools.
- The official Herdr Pi integration, installed with `herdr integration install pi`
  when Herdr is present and integration is enabled. Do not copy or fork its
  generated TypeScript file.

The controller had Powerline 0.16.0 and xAI 1.5.2 installed. Both declared peer
ranges that excluded Pi 0.85. The selected newer releases declare support for
Pi 0.85.1. Versions are pinned in `defaults/main.yml`; update them together after
checking compatibility. The npm manifest also uses exact versions, so installing
another package cannot silently widen these pins. Extensions run with the
development user's access; review package changes before updating them.

## Safe configuration handling

This is an explicit configuration snapshot, not a recursive copy of `~/.pi`.
The role merges its selected preferences into target settings. Other settings,
extra packages, and instructions outside the managed block remain in place.
Existing settings are not printed in Ansible output or diffs. Run the role while
Pi is closed so another Pi process cannot write settings during deployment.

The role does not copy or manage:

- `auth.json`, API keys, OAuth tokens, or Grok credentials
- `models-store.json`, machine-specific model catalogs, or `trust.json`
- session history, caches, logs, queued prompts, or Powerline inboxes
- arbitrary local extensions, prompt files, or skill symlinks

Login and project trust remain per-device decisions. No provider requests or
paid model calls are needed for installation. Vision handoff needs a describer
selected with `/vision-handoff` before it can process images. Extra xAI network
tools remain opt-in.

## Run

On a machine where mise and Node.js are already set up:

```bash
./bootstrap gui --tags pi -- --limit HOST
```

For a new machine, use the full playbook or include the runtime tags:

```bash
./bootstrap gui --tags mise,herdr,pi -- --limit HOST
```

Start `pi`, run `/login`, then choose an available model with `/model`. The
preferred model may depend on account access. Use `pi list` to inspect packages
and `/reload` after configuration changes.

The role inspects installed npm versions and skips matching installations. It
reinstalls missing or mismatched packages, and registers a missing package source
without duplicating it. After switching the global mise Node.js version, rerun
the role to install the CLI in that Node.js installation.

Override `pi_preferences`, `pi_packages`, or `pi_version` through inventory for
intentional per-host differences. `pi_agent_dir` can select a separate test
configuration. `pi_extra_environment` supports isolated npm prefixes for tests;
never put credentials in tracked inventory.
