"""Offline tests for the shell batch used by the cargo-binstall role.

Run with: python3 -m unittest discover -s tests -v
Requires PyYAML and Jinja2, which are also Ansible dependencies.
"""

import json
import os
from pathlib import Path
import shlex
import subprocess
import tempfile
import unittest

from jinja2 import Environment, StrictUndefined
import yaml


ROOT = Path(__file__).resolve().parents[1]
TASKS = yaml.safe_load((ROOT / "roles/cargo-binstall/tasks/main.yml").read_text())
BATCH = next(task for task in TASKS[0]["block"] if "shell" in task)


class CargoBinstallBatchTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="cargo-binstall-test-")
        self.addCleanup(self.temp.cleanup)
        self.home = Path(self.temp.name)
        self.bin = self.home / ".cargo/bin"
        self.bin.mkdir(parents=True)
        self.log = self.home / "calls.jsonl"
        self.write_binary(
            "cargo-binstall",
            "#!/usr/bin/env python3\n"
            "import json, os, pathlib, sys\n"
            "home = pathlib.Path(os.environ['HOME'])\n"
            "with (home / 'calls.jsonl').open('a') as log:\n"
            "    log.write(json.dumps(sys.argv[1:]) + '\\n')\n"
            "if os.environ.get('SIMULATE_FAILURE'):\n"
            "    print('No compatible binary for unavailable-crate', file=sys.stderr)\n"
            "    sys.exit(1)\n"
            "for name in os.environ.get('INSTALL_BINARIES', '').split():\n"
            "    binary = home / '.cargo/bin' / name\n"
            "    binary.write_text('#!/bin/sh\\nexit 0\\n')\n"
            "    binary.chmod(0o755)\n",
        )

    def write_binary(self, name, content="#!/bin/sh\nexit 0\n"):
        path = self.bin / name
        path.write_text(content)
        path.chmod(0o755)

    def run_batch(self, tools, **extra_env):
        env = Environment(undefined=StrictUndefined)
        env.filters["quote"] = shlex.quote
        script = env.from_string(BATCH["shell"]).render(cargo_binstall_tools=tools)
        return subprocess.run(
            ["/bin/bash", "-c", script],
            env={**os.environ, "HOME": str(self.home), **extra_env},
            text=True,
            capture_output=True,
            check=False,
        )

    def test_batches_missing_crates_and_skips_installed_binaries(self):
        self.write_binary("test-existing")
        tools = [
            {"package": "already-installed", "binary": "test-existing"},
            {"package": "du-dust", "binary": "test-dust"},
            {"package": "bottom", "binary": "test-btm"},
        ]
        result = self.run_batch(tools, INSTALL_BINARIES="test-dust test-btm")
        self.assertEqual(result.returncode, 0, result.stderr)
        calls = self.log.read_text().splitlines()
        self.assertEqual(len(calls), 1)
        self.assertEqual(
            json.loads(calls[0]),
            ["--no-confirm", "--disable-strategies", "compile",
             "--continue-on-failure", "du-dust", "bottom"],
        )
        self.assertIn("Installing missing Cargo tools:", result.stdout)

        result = self.run_batch(tools)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, "")
        self.assertEqual(len(self.log.read_text().splitlines()), 1)

    def test_empty_list_does_not_invoke_binstall(self):
        result = self.run_batch([])
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(self.log.exists())

    def test_failure_is_available_for_ansible_warning(self):
        result = self.run_batch(
            [{"package": "unavailable-crate", "binary": "test-unavailable"}],
            SIMULATE_FAILURE="1",
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("No compatible binary", result.stderr)
        self.assertFalse(BATCH["failed_when"])
        self.assertIn("--continue-on-failure", json.loads(self.log.read_text()))

    def test_crate_names_are_shell_quoted(self):
        marker = self.home / "injected"
        package = f"bad; touch {marker}"
        result = self.run_batch([{"package": package, "binary": "test-missing"}])
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(json.loads(self.log.read_text())[-1], package)
        self.assertFalse(marker.exists())


if __name__ == "__main__":
    unittest.main()
