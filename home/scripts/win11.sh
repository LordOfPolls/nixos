#!/usr/bin/env bash

VM="win11"
RDP_USER="user"
RDP_PORT=3389
BOOT_TIMEOUT=180
RDP_TIMEOUT=60

get_state() {
    virsh domstate "$VM" 2>/dev/null | tr -d '[:space:]'
}

get_ip() {
    virsh domifaddr "$VM" 2>/dev/null \
        | grep -oP '\d+\.\d+\.\d+\.\d+' \
        | grep -v '^169\.' \
        | head -1
}

wait_for_ip() {
    local deadline=$((SECONDS + BOOT_TIMEOUT))
    while [[ $SECONDS -lt $deadline ]]; do
        local ip
        ip=$(get_ip)
        [[ -n "$ip" ]] && { echo "$ip"; return 0; }
        sleep 5
    done
    return 1
}

wait_for_rdp() {
    local ip="$1"
    local deadline=$((SECONDS + RDP_TIMEOUT))
    while [[ $SECONDS -lt $deadline ]]; do
        nc -z -w2 "$ip" "$RDP_PORT" 2>/dev/null && return 0
        sleep 3
    done
    return 1
}

case "$1" in
    status)
        STATE=$(get_state)
        if [[ "$STATE" == "running" ]]; then
            echo '{"text": "  win11", "class": "running", "tooltip": "Windows 11: running\nClick to connect"}'
        else
            echo '{"text": "  win11", "class": "stopped", "tooltip": "Windows 11: stopped\nClick to start + connect"}'
        fi
        ;;

    launch)
        STATE=$(get_state)
        if [[ "$STATE" != "running" ]]; then
            notify-send "Windows 11" "Starting VM..." -i computer
            virsh start "$VM" >/dev/null 2>&1 || {
                notify-send "Windows 11" "Failed to start VM" -u critical
                exit 1
            }
        fi

        notify-send "Windows 11" "Waiting for network..." -i computer
        IP=$(wait_for_ip) || {
            notify-send "Windows 11" "Timed out waiting for IP address" -u critical
            exit 1
        }

        notify-send "Windows 11" "Waiting for RDP on $IP..." -i computer
        wait_for_rdp "$IP" || {
            notify-send "Windows 11" "RDP not responding on $IP:$RDP_PORT" -u critical
            exit 1
        }

        notify-send "Windows 11" "Connecting to $IP..." -i computer
        xfreerdp /u:"$RDP_USER" /v:"$IP:$RDP_PORT" /dynamic-resolution /cert:ignore &
        ;;
esac
