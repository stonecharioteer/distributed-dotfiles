# Prebuilt Cargo tools

This shared role serves `rust-toolchain` and `cli-tools` on Linux and macOS.

- Install a pinned upstream `cargo-binstall` binary when it is missing. Verify the archive with its SHA-256 digest before extraction.
- Support Linux x86_64/aarch64 and macOS Intel/Apple Silicon. Unsupported platforms fail without compiling a replacement.
- Keep an existing executable `cargo-binstall`. No download or release lookup is needed on reruns.
- Check each tool's executable before requesting its crate. Package and executable names can differ, such as `bottom` and `btm`.
- Pass all missing crates to one `cargo-binstall` process. It resolves and downloads packages concurrently and manages its own installation locks.
- Use `--disable-strategies compile` to prevent automatic source builds.
- Use `--continue-on-failure` so one unavailable binary does not stop the remaining packages. Report the error after the batch.

The roles run their batches in sequence. Do not run separate background installers against the same Cargo home. Downloads can overlap within a batch without separate Ansible processes.

## Explicit source fallback

If a package has no compatible binary, first check for a package-manager alternative. To build a selected crate on the target, run:

```bash
cargo install --locked <crate>
```

Source builds can use substantial CPU, memory, and time. They are never an automatic fallback in these roles.

## Updates

Installed tools are left unchanged. To request an update explicitly, run:

```bash
cargo binstall --no-confirm --disable-strategies compile <crate>
```

For a new bootstrap release, update `cargo_binstall_version` and the matching archive digests in `defaults/main.yml` together. The digests come from the official GitHub release assets. A version change alone does not upgrade an existing executable.

## Tests

```bash
uv run --no-project --with pyyaml --with jinja2 --python 3.11 python -m unittest discover -s tests -v
uvx pre-commit run --all-files
```

The offline tests cover one-process batching, installed-tool skips, reruns, empty lists, error reporting inputs, and shell quoting. They do not measure real network performance.
