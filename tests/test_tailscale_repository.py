"""Offline tests for Tailscale's base-distribution repository selection."""

import os
from pathlib import Path
import subprocess
import tempfile
import unittest

from jinja2 import Environment, StrictUndefined
import yaml


ROOT = Path(__file__).resolve().parents[1]
TASKS = yaml.safe_load((ROOT / "roles/tailscale/tasks/main.yml").read_text())
INSTALL = next(task["block"] for task in TASKS if "block" in task)
RESOLVE = next(task for task in INSTALL if "shell" in task)


class TailscaleRepositoryTests(unittest.TestCase):
    def resolve(self, content):
        with tempfile.TemporaryDirectory(prefix="tailscale-os-release-") as directory:
            os_release = Path(directory) / "os-release"
            os_release.write_text(content)
            script = RESOLVE["shell"].replace(
                ". /etc/os-release", '. "$TEST_OS_RELEASE"'
            )
            env = {key: value for key, value in os.environ.items()
                   if key not in {"ID", "UBUNTU_CODENAME", "VERSION_CODENAME"}}
            return subprocess.run(
                ["/bin/sh", "-c", script],
                env={**env, "TEST_OS_RELEASE": str(os_release)},
                text=True,
                capture_output=True,
                check=False,
            )

    def test_supported_distributions(self):
        fixtures = [
            ('ID=linuxmint\nVERSION_CODENAME=zena\nUBUNTU_CODENAME=noble\n', 'ubuntu/noble'),
            ('ID=linuxmint\nVERSION_CODENAME=virginia\nUBUNTU_CODENAME=jammy\n', 'ubuntu/jammy'),
            ('ID=ubuntu\nVERSION_CODENAME=noble\n', 'ubuntu/noble'),
            ('ID=debian\nVERSION_CODENAME=bookworm\n', 'debian/bookworm'),
            ('ID=debian\nVERSION_CODENAME=trixie\n', 'debian/trixie'),
        ]
        for content, expected in fixtures:
            with self.subTest(expected=expected, content=content):
                result = self.resolve(content)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(result.stdout.strip(), expected)

    def test_unsupported_or_incomplete_metadata_fails(self):
        fixtures = [
            'ID=linuxmint\nVERSION_CODENAME=zena\n',
            'ID=ubuntu\n',
            'ID=ubuntu\nVERSION_CODENAME="bad name"\n',
            'ID=ubuntu\nVERSION_CODENAME="../noble"\n',
            '',
        ]
        for content in fixtures:
            with self.subTest(content=content):
                result = self.resolve(content)
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(result.stdout, '')
                self.assertTrue(result.stderr)

    def test_both_downloads_use_resolved_base(self):
        env = Environment(undefined=StrictUndefined)
        urls = [
            env.from_string(task['get_url']['url']).render(
                tailscale_repository_path={'stdout': 'ubuntu/noble\n'}
            )
            for task in INSTALL if 'get_url' in task
        ]
        self.assertEqual(urls, [
            'https://pkgs.tailscale.com/stable/ubuntu/noble.noarmor.gpg',
            'https://pkgs.tailscale.com/stable/ubuntu/noble.tailscale-keyring.list',
        ])
        self.assertFalse(RESOLVE['check_mode'])
        self.assertFalse(RESOLVE['changed_when'])


if __name__ == '__main__':
    unittest.main()
