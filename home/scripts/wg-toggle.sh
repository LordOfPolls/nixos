#!/usr/bin/env bash
INTERFACE_DIR="/etc/wireguard"
LOG="/tmp/wg-toggle.log"

get_active() {
    ip link show type wireguard 2>/dev/null | grep -oP '^\d+: \K\w+'
}

wg_run() {
    sudo -n wg-quick "$@" >> "$LOG" 2>&1
    local rc=$?
    [ $rc -ne 0 ] && notify-send "WireGuard error" "wg-quick $* failed (rc=$rc). See $LOG"
    return $rc
}

refresh() {
    rm -f /tmp/waybar-ip-cache
    pkill -RTMIN+8 waybar
}

case "$1" in
  toggle)
    ACTIVE=$(get_active)
    if [ -n "$ACTIVE" ]; then
        wg_run down "$ACTIVE"
    else
        CONFIGS=($(ls "$INTERFACE_DIR"/*.conf 2>/dev/null | xargs -I{} basename {} .conf))
        if [ ${#CONFIGS[@]} -eq 0 ]; then
            notify-send "WireGuard" "No configs found in $INTERFACE_DIR"
            exit 1
        fi
        PICK="${CONFIGS[$RANDOM % ${#CONFIGS[@]}]}"
        notify-send "WireGuard" "Connecting to $PICK..."
        wg_run up "$PICK"
    fi
    refresh
    ;;

  pick)
    ACTIVE=$(get_active)
    CONFIGS=$(ls "$INTERFACE_DIR"/*.conf 2>/dev/null | xargs -I{} basename {} .conf | sort)

    if [ -z "$CONFIGS" ]; then
        notify-send "WireGuard" "No configs found in $INTERFACE_DIR"
        exit 1
    fi

    MENU=""
    [ -n "$ACTIVE" ] && MENU="⨯  Disconnect\n"

    while IFS= read -r cfg; do
        if [ "$cfg" = "$ACTIVE" ]; then
            MENU+="●  $cfg\n"
        else
            MENU+="○  $cfg\n"
        fi
    done <<< "$CONFIGS"

    CHOICE=$(printf "%b" "$MENU" | wofi --dmenu --prompt "VPN" --width 280 --lines 8 --insensitive)
    [ -z "$CHOICE" ] && exit 0

    if [[ "$CHOICE" == "⨯  Disconnect" ]]; then
        wg_run down "$ACTIVE"
    else
        CFG=$(echo "$CHOICE" | sed 's/^[●○]  //')
        [ -n "$ACTIVE" ] && [ "$ACTIVE" != "$CFG" ] && wg_run down "$ACTIVE"
        wg_run up "$CFG"
    fi
    refresh
    ;;

  status)
    ACTIVE=$(get_active)
    if [ -n "$ACTIVE" ]; then
        echo "{\"text\": \"󰒄  $ACTIVE\", \"class\": \"connected\", \"tooltip\": \"WireGuard: $ACTIVE\"}"
    else
        echo '{"text": "󰒄  VPN", "class": "disconnected", "tooltip": "WireGuard: disconnected"}'
    fi
    ;;
esac
