#!/bin/bash
# pcomp-selfheal — after boot and then every few minutes, makes sure the pieces
# a power loss used to leave down are up: pcomp's killswitch, the vpnvm networks,
# the vpngw container and vpnvm itself. It only ever starts things, never stops them.
# Whatever it had to fix (or could not) goes to the journal and as a notice to the mac.
# Signed: pluttan

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/incus/bin

log() { echo "$*"; fixed+="$*"$'\n'; }
fixed=""

# Killswitch first: without proxyguard a dead sing-box means pcomp talks to the ISP directly.
if ! nft list table inet proxyguard >/dev/null 2>&1; then
    nft -f /etc/nftables.conf && log "proxyguard загружен" || log "proxyguard НЕ загружается: nft -c -f /etc/nftables.conf"
fi

for net in vpnlan vpnhost; do
    if ! virsh net-list --name | grep -qx "$net"; then
        virsh net-start "$net" >/dev/null && log "сеть $net поднята" || log "сеть $net НЕ поднимается"
    fi
    virsh net-autostart "$net" >/dev/null 2>&1
done

systemctl is-active -q vpnvm-host || { systemctl start vpnvm-host && log "vpnvm-host запущен" || log "vpnvm-host НЕ запускается"; }

if [ "$(incus list vpngw -c s -f csv 2>/dev/null)" != RUNNING ]; then
    incus start vpngw && log "vpngw запущен" || log "vpngw НЕ запускается: incus info vpngw --show-log"
fi

if ! virsh list --name | grep -qx vpnvm; then
    virsh start vpnvm >/dev/null && log "vpnvm запущена" || log "vpnvm НЕ запускается"
fi

[ -z "$fixed" ] && exit 0
# The mac shows it as a system notice; when the mac is away the journal keeps it.
msg=$(printf '%s' "$fixed" | tr '\n' ';' | sed 's/;$//; s/"/\\"/g')
sudo -u pluttan ssh -o BatchMode=yes -o ConnectTimeout=8 macair \
    "osascript -e 'display notification \"$msg\" with title \"pcomp selfheal\"'" >/dev/null 2>&1 || true
