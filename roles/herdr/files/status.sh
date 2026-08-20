#!/bin/sh
# Compact right-status for herdr. Print one short line. No chevrons.
# Portable across macOS and Linux. Battery output is omitted on machines
# without a battery.

load=""
if [ -r /proc/loadavg ]; then
  load=$(awk '{ print $1 }' /proc/loadavg)
elif command -v sysctl >/dev/null 2>&1; then
  load=$(sysctl -n vm.loadavg 2>/dev/null | awk '{ print $2 }')
fi
if [ -z "${load}" ]; then
  load=$(uptime | awk -F'load averages?: |load average: ' '{ print $2 }' | awk -F, '{ print $1 }' | tr -d ' ')
fi

batt=""

if command -v pmset >/dev/null 2>&1; then
  batt_line=$(pmset -g batt 2>/dev/null | awk '/InternalBattery/ { print $0 }')
  if [ -n "${batt_line}" ]; then
    pct=$(printf '%s\n' "${batt_line}" | awk -F'\t' '{ print $2 }' | awk -F';' '{ print $1 }' | tr -d ' ')
    state=$(printf '%s\n' "${batt_line}" | awk -F';' '{ print $2 }' | sed 's/^ *//;s/ *$//')
    case "${state}" in
      charged|charged*) icon="AC" ;;
      charging|charging*) icon="CHG" ;;
      discharging|discharging*) icon="BAT" ;;
      *) icon="BAT" ;;
    esac
    batt="${icon} ${pct}"
  fi
fi

if [ -z "${batt}" ]; then
  for bat in /sys/class/power_supply/BAT*; do
    [ -d "${bat}" ] || continue
    cap=""
    status=""
    if [ -r "${bat}/capacity" ]; then
      cap=$(tr -d '\n' < "${bat}/capacity")
    fi
    if [ -r "${bat}/status" ]; then
      status=$(tr -d '\n' < "${bat}/status")
    fi
    if [ -n "${cap}" ]; then
      case "${status}" in
        Full) icon="AC" ;;
        Charging) icon="CHG" ;;
        Discharging) icon="BAT" ;;
        *) icon="BAT" ;;
      esac
      batt="${icon} ${cap}%"
      break
    fi
  done
fi

if [ -n "${batt}" ]; then
  printf 'L %s | %s\n' "${load}" "${batt}"
else
  printf 'L %s\n' "${load}"
fi
