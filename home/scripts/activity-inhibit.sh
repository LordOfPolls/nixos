#!/usr/bin/env bash

# Thresholds
CPU_THRESHOLD=30       # percent
GPU_THRESHOLD=10       # percent
NET_THRESHOLD=1048576  # bytes/sec (1 MB/s)
CHECK_INTERVAL=15      # seconds

DEBUG=${DEBUG:-0}
while getopts ':d' opt; do
  case $opt in
    d) DEBUG=1 ;;
  esac
done
inhibit_pid=""

cleanup() {
  [[ -n "$inhibit_pid" ]] && kill "$inhibit_pid" 2>/dev/null
  exit 0
}
trap cleanup EXIT TERM INT

cpu_sample() {
  awk '/^cpu /{print $2+$3+$4+$5+$6+$7+$8, $5}' /proc/stat
}

net_bytes() {
  awk '/^\s*[a-z]/ && !/lo:/ {
    gsub(/:/, " "); rx += $2; tx += $10
  } END { print rx + tx }' /proc/net/dev
}

gpu_pct() {
  command -v nvidia-smi &>/dev/null || { echo 0; return; }
  nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null \
    | awk '{s += $1; n++} END { print (n > 0 ? int(s / n) : 0) }'
}

prev_cpu=$(cpu_sample)
prev_net=$(net_bytes)

while sleep "$CHECK_INTERVAL"; do
  curr_cpu=$(cpu_sample)
  curr_net=$(net_bytes)

  # CPU %
  read -r prev_total prev_idle <<< "$prev_cpu"
  read -r curr_total curr_idle <<< "$curr_cpu"
  dt=$(( curr_total - prev_total ))
  di=$(( curr_idle  - prev_idle ))
  cpu=$(( dt > 0 ? (dt - di) * 100 / dt : 0 ))
  prev_cpu="$curr_cpu"

  # Network bytes/sec
  net=$(( (curr_net - prev_net) / CHECK_INTERVAL ))
  prev_net="$curr_net"

  # GPU %
  gpu=$(gpu_pct)

  (( DEBUG )) && echo "stats: cpu=${cpu}% gpu=${gpu}% net=$(( net / 1024 ))KB/s inhibit=${inhibit_pid:-none}" >&2

  # Stale-PID check
  if [[ -n "$inhibit_pid" ]] && ! kill -0 "$inhibit_pid" 2>/dev/null; then
    inhibit_pid=""
  fi

  if (( cpu > CPU_THRESHOLD || gpu > GPU_THRESHOLD || net > NET_THRESHOLD )); then
    if [[ -z "$inhibit_pid" ]]; then
      echo "inhibiting sleep: cpu=${cpu}% gpu=${gpu}% net=$(( net / 1024 ))KB/s" >&2
      systemd-inhibit \
        --what=sleep \
        --who=activity-inhibit \
        --why="cpu=${cpu}% gpu=${gpu}% net=$(( net / 1024 ))KB/s" \
        --mode=block \
        sleep infinity &
      inhibit_pid=$!
    fi
  else
    if [[ -n "$inhibit_pid" ]]; then
      echo "releasing sleep inhibit" >&2
      kill "$inhibit_pid" 2>/dev/null
      wait "$inhibit_pid" 2>/dev/null
      inhibit_pid=""
    fi
  fi
done
