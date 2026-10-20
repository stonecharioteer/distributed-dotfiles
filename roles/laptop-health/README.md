# Laptop power policy

## GUI lid behavior

Enable the policy for a GUI laptop in its private host variables:

```yaml
enable_laptop_lid_policy: true
enable_laptop_lid_ignore: false
laptop_lid_battery_delay_seconds: 300
```

The policy keeps a closed laptop awake on external power. On battery, the lid
must remain closed for five continuous minutes before it requests suspension.
Opening the lid or reconnecting power cancels the timer. Unplugging a closed
laptop starts the timer. Sensor checks run every ten seconds, so action can lag
by one polling interval. Unknown sensor state cancels the timer.

This controls lid-close suspension. It does not override manual suspend,
critical-battery actions, or independent idle-suspend settings.

## Helper and activation

The runtime helper belongs to `stonecharioteer/scripts` at
`laptop/lid-power-policy.py`. Update that checkout on the target before enabling
this feature. The scripts setup role preserves existing checkouts; it does not
pull updates automatically.

For a helper from a local scripts checkout, set an explicit controller path:

```yaml
laptop_lid_policy_controller_source: /path/to/scripts/laptop/lid-power-policy.py
```

Ansible copies the helper to a root-owned path under `/usr/local/libexec`. The
service does not execute mutable code from the user's checkout. A read-only
sensor check must pass before the role changes desktop lid settings.

The service holds logind's `handle-lid-switch` inhibitor. It does not restart
logind or disable manual suspension. Cinnamon dconf policy and Xfce system
property locks disable each desktop's separate immediate lid actions. Other
Xfce system properties and the user's stored preferences are preserved.
Xfce system defaults are backed up once under `/var/lib/laptop-lid-policy`.
Do not edit that system XML while this policy is enabled, because disabling
the policy restores the saved file.

Apply the role, then reboot once so desktop sessions read the new system policy:

```bash
./bootstrap gui --tags laptop -- --limit HOST
```

Check operation after reboot:

```bash
systemctl status laptop-lid-policy.service
journalctl -u laptop-lid-policy.service
systemd-inhibit --list
/usr/bin/python3 /usr/local/libexec/laptop-lid-policy.py --check
```

Test with the laptop accessible: close the lid on external power, then unplug
it and wait five minutes. Opening the lid before the delay ends must cancel
suspension. Do not perform the unplug test while a remote operation must remain
connected.

To disable the policy, set `enable_laptop_lid_policy: false` and rerun the
`laptop-health` role. Keep a laptop feature enabled so the playbook still runs
that role, or run it explicitly. It stops the service, removes the managed
Cinnamon policy, and restores the saved Xfce system defaults. Reboot after
changing the policy.
