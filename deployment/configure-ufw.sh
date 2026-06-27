#!/bin/bash
set -euo pipefail

if ! command -v ufw >/dev/null 2>&1; then
    echo "[UFW] ufw is not installed; skipping firewall configuration"
    exit 0
fi

if [ "${OPENMEET_CONFIGURE_UFW:-true}" != "true" ]; then
    echo "[UFW] OPENMEET_CONFIGURE_UFW is not true; skipping firewall configuration"
    exit 0
fi

SSH_PORT="${SSH_PORT:-22}"

echo "[UFW] Configuring host firewall for OpenMeet"

ufw_status() {
    sudo ufw status verbose
}

ufw_has_rule() {
    local rule="$1"
    ufw_status | grep -Eq "^${rule//\//\/}[[:space:]]+ALLOW IN"
}

ensure_allow() {
    local rule="$1"
    local comment="$2"

    if ufw_has_rule "$rule"; then
        echo "[UFW] Rule already present: $rule"
        return
    fi

    echo "[UFW] Adding rule: $rule"
    sudo ufw allow "$rule" comment "$comment"
}

remove_if_present() {
    local rule="$1"

    if ! ufw_has_rule "$rule"; then
        echo "[UFW] Stale rule absent: $rule"
        return
    fi

    echo "[UFW] Removing stale rule: $rule"
    sudo ufw --force delete allow "$rule" >/dev/null 2>&1 || true
}

current_defaults="$(ufw_status)"

if ! grep -q "Default: deny (incoming)" <<<"$current_defaults"; then
    sudo ufw default deny incoming
else
    echo "[UFW] Incoming default already deny"
fi

if ! grep -q "allow (outgoing)" <<<"$current_defaults"; then
    sudo ufw default allow outgoing
else
    echo "[UFW] Outgoing default already allow"
fi

if ! grep -q "deny (routed)" <<<"$current_defaults"; then
    sudo ufw default deny routed
else
    echo "[UFW] Routed default already deny"
fi

ensure_allow "${SSH_PORT}/tcp" 'SSH'

if [ "$SSH_PORT" != "22" ]; then
    # Keep standard SSH open as a safety net for deployments that still connect on 22.
    ensure_allow "22/tcp" 'SSH fallback'
fi

ensure_allow "80/tcp" 'HTTP and Lets Encrypt'
ensure_allow "443/tcp" 'HTTPS frontend API WebSocket Grafana'
ensure_allow "3478/udp" 'TURN STUN UDP'
ensure_allow "3478/tcp" 'TURN STUN TCP fallback'
ensure_allow "5349/tcp" 'TURN TLS'
ensure_allow "49152:65535/udp" 'TURN relay and SFU media UDP range'

STALE_RULES=(
    5349/udp
    21820/udp
    51280/udp
    18789/tcp
    8080/tcp
)

for rule in "${STALE_RULES[@]}"; do
    remove_if_present "$rule"
done

if sudo ufw status | grep -q "Status: active"; then
    echo "[UFW] Firewall already active"
else
    sudo ufw --force enable
fi

sudo ufw reload

echo "[UFW] Active firewall rules:"
sudo ufw status verbose
