"""Offline regression checks for Pi's pinned installation and configuration."""

import json
from pathlib import Path
import unittest

from jinja2 import StrictUndefined
from jinja2.nativetypes import NativeEnvironment
import yaml


ROOT = Path(__file__).resolve().parents[1]
ROLE = ROOT / "roles/pi-config"
DEFAULTS = yaml.safe_load((ROLE / "defaults/main.yml").read_text())
TASKS = yaml.safe_load((ROLE / "tasks/main.yml").read_text())[0]
BY_NAME = {task["name"]: task for task in TASKS["block"]}


class PiConfigTests(unittest.TestCase):
    def setUp(self):
        self.env = NativeEnvironment(undefined=StrictUndefined)
        self.env.filters["from_json"] = json.loads

    def needs_install(self, version="0.2.0", spec="0.2.0", sources=None):
        task = BY_NAME["Install or register selected Pi extensions"]
        expression = self.env.compile_expression(task["when"][1])
        return expression(
            item={"name": "pi-codex-goal", "version": "0.2.0"},
            pi_extension_npm={"stdout": json.dumps({
                "dependencies": {"pi-codex-goal": {"version": version}}
            })},
            pi_npm_specs={"pi-codex-goal": spec},
            pi_configured_sources=(
                ["npm:pi-codex-goal@0.2.0"] if sources is None else sources
            ),
        )

    def test_matching_version_spec_and_registration_skip_install(self):
        self.assertFalse(self.needs_install())

    def test_missing_mismatched_or_unpinned_install_is_repaired(self):
        for overrides in (
            {"version": ""}, {"version": "0.2.1"}, {"spec": "^0.2.0"},
            {"spec": ""}, {"sources": []}, {"sources": ["npm:pi-codex-goal"]},
        ):
            with self.subTest(overrides=overrides):
                self.assertTrue(self.needs_install(**overrides))

    def test_filtered_package_entries_are_recognized(self):
        expression = BY_NAME["Collect configured Pi package sources"]["set_fact"]["pi_configured_sources"]
        sources = self.env.from_string(expression).render(pi_existing_settings={
            "packages": ["npm:extra-package", {
                "source": "npm:pi-codex-goal@0.2.0", "extensions": ["src/index.ts"]
            }]
        })
        self.assertEqual(sources, ["npm:extra-package", "npm:pi-codex-goal@0.2.0"])
        self.assertFalse(self.needs_install(sources=sources))
        self.assertEqual(self.env.from_string(expression).render(pi_existing_settings={}), [])

    def test_all_primary_playbooks_include_pi_after_runtime_and_herdr(self):
        for name in ("base-environment", "gui-environment", "macos-base-environment", "macos-gui-environment"):
            with self.subTest(playbook=name):
                play = yaml.safe_load((ROOT / f"playbooks/{name}.yml").read_text())[0]
                roles = [entry["role"] for entry in play["roles"]]
                self.assertLess(roles.index("mise-tools"), roles.index("pi-config"))
                self.assertLess(roles.index("herdr"), roles.index("pi-config"))
                role = play["roles"][roles.index("pi-config")]
                self.assertIn("pi", role["tags"])
                self.assertEqual(role["when"], "enable_pi | bool")

    def test_settings_are_explicit_and_not_logged(self):
        self.assertEqual(set(DEFAULTS["pi_preferences"]), {
            "defaultProvider", "defaultModel", "defaultThinkingLevel", "hideThinkingBlock", "theme"
        })
        for name in (
            "Read existing Pi settings without exposing local values",
            "Preserve unrelated Pi settings",
            "Build shared Pi preferences without replacing unrelated settings",
            "Merge shared Pi preferences",
        ):
            self.assertTrue(BY_NAME[name]["no_log"])
        merge = BY_NAME["Merge shared Pi preferences"]
        self.assertFalse(merge["diff"])
        self.assertEqual(merge["copy"]["mode"], "0600")
        self.assertEqual(merge["when"], "pi_desired_settings != pi_existing_settings")
        instructions = BY_NAME["Add shared Pi agent instructions"]["blockinfile"]
        self.assertIn("role_path", instructions["block"])

    def test_versions_are_exact_and_lifecycle_scripts_disabled(self):
        self.assertRegex(DEFAULTS["pi_version"], r"^\d+\.\d+\.\d+$")
        self.assertEqual(len(DEFAULTS["pi_packages"]), 5)
        for package in DEFAULTS["pi_packages"]:
            self.assertRegex(package["version"], r"^\d+\.\d+\.\d+$")
        self.assertIn("'npm_config_save_exact': 'true'", TASKS["environment"])
        self.assertIn("'npm_config_ignore_scripts': 'true'", TASKS["environment"])
        cli = BY_NAME["Install the selected Pi CLI version"]["command"]["argv"]
        self.assertIn("--ignore-scripts", cli)
        packages = BY_NAME["Install or register selected Pi extensions"]
        self.assertIn("--no-approve", packages["command"]["argv"])
        self.assertIn("not ansible_check_mode", packages["when"])


if __name__ == "__main__":
    unittest.main()
