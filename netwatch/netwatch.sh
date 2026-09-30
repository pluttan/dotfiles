#!/bin/bash
# netwatch — сторож Wi-Fi на маке: раз в 20 с пишет, к какой точке подключён мак
# и какое звено отвечает — роутер, интернет в обход VPN, интернет через VPN.
#   netwatch.sh run            цикл (его держит LaunchAgent com.pluttan.netwatch)
#   netwatch.sh report [дней]  эпизоды без интернета и чем они кончились
# Signed: pluttan

LOGDIR="$HOME/Library/Logs/netwatch"
ROUTER=192.168.1.1
PROBE=1.1.1.1
URL=https://www.gstatic.com/generate_204

wifi() {
    # Канал, частота, режим и сигнал — по ним видно, к какому роутеру прилип мак.
    system_profiler SPAirPortDataType 2>/dev/null | awk '
        /Current Network Information:/ {on=1; next}
        on && /Other Local Wi-Fi Networks:/ {exit}
        on && /PHY Mode:/      {phy=$3}
        on && /Channel:/       {sub(/.*Channel: /,""); gsub(/ /,""); ch=$0}
        on && /Signal \/ Noise:/ {sig=$4}
        on && /Transmit Rate:/ {rate=$3}
        END {printf "ch=%s phy=%s sig=%s rate=%s", (ch?ch:"-"), (phy?phy:"-"), (sig?sig:"-"), (rate?rate:"-")}'
}

ok() { "$@" >/dev/null 2>&1 && echo ok || echo FAIL; }

run() {
    mkdir -p "$LOGDIR"
    while :; do
        ip=$(ipconfig getifaddr en0 || echo -)
        lan=$(ok ping -c1 -t2 -b en0 "$ROUTER")   # мимо VPN-туннеля
        direct=$(ok ping -c1 -t2 -b en0 "$PROBE")
        code=$(curl -s -m6 -o /dev/null -w '%{http_code}' "$URL")
        [ "$code" = 204 ] && via=ok || via="FAIL($code)"
        printf '%s ip=%s %s lan=%s direct=%s vpn=%s\n' "$(date '+%F %T')" "$ip" "$(wifi)" \
            "$lan" "$direct" "$via" >> "$LOGDIR/$(date +%F).log"
        find "$LOGDIR" -name '*.log' -mtime +14 -delete 2>/dev/null
        sleep 20
    done
}

report() {
    # Эпизод — подряд идущие строки, где хоть одна проверка не прошла.
    days=${1:-1}
    find "$LOGDIR" -name '*.log' -mtime -"$days" | sort | xargs cat 2>/dev/null | awk '
        function verdict() {
            if (l=="FAIL") return "Wi-Fi: даже роутер не отвечает"
            if (d=="FAIL" && v!="ok") return "интернет/провайдер: роутер отвечает, наружу нет"
            if (d=="ok" && v!="ok") return "VPN: напрямую интернет есть, через VPN нет"
            if (d=="FAIL" && v=="ok") return "только прямой пинг (VPN работает) — не страшно"
            return "?"
        }
        {
            split($0, f, " "); l=d=v=""
            for (i in f) { if (f[i] ~ /^lan=/) l=substr(f[i],5); if (f[i] ~ /^direct=/) d=substr(f[i],8); if (f[i] ~ /^vpn=/) v=substr(f[i],5) }
            bad = (l!="ok" || v!="ok")
            if (bad && !inside) { inside=1; start=$1" "$2; first=$0; why=verdict() }
            if (!bad && inside) { inside=0; printf "%s → %s  %s\n    %s\n", start, $2, why, first; n++ }
        }
        END { if (inside) printf "%s → сейчас  %s\n    %s\n", start, why, first; if (!n && !inside) print "обрывов не было" }'
}

case "${1:-}" in
    run) run ;;
    report) report "${2:-1}" ;;
    *) sed -n '2,6p' "$0" | sed 's/^# \{0,1\}//'; exit 1 ;;
esac
