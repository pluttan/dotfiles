#!/bin/bash
# kittywall — каждый раз новый фон kitty на маке. Картинка берётся случайной
# с wallhaven.cc по одной из тем QUERIES; уже показанные запоминаются в seen и
# второй раз не попадаются. Нет сети — по кругу из своего пула
# dotfiles/kitty/wallpapers. Картинка ужимается до 2560 px в PNG, кладётся в
# CURRENT (на него смотрит background_image в kitty.conf, так новые окна сразу
# открываются с ней) и отправляется во все запущенные kitty через remote
# control (listen_on unix:/tmp/kitty-sock-<pid>).
#   kittywall.sh next   новая картинка (её раз в 15 минут зовёт LaunchAgent)
#   kittywall.sh keep   понравилась — сохранить текущую в пул
#   kittywall.sh info   что сейчас на фоне
# Signed: pluttan

POOL=/Volumes/pr/dotfiles/kitty/wallpapers
STATE="$HOME/.local/share/kittywall"
CURRENT="$STATE/current.png"
KITTY=/Applications/kitty.app/Contents/MacOS/kitty
API=https://wallhaven.cc/api/v1/search
QUERIES=("landscape" "mountains" "lighthouse" "pixel art landscape" "night city" "forest" "sea" "digital art landscape")

# Случайная непоказанная картинка с wallhaven: печатает "id url" или ничего.
pick_remote() {
    local query
    query=${QUERIES[RANDOM % ${#QUERIES[@]}]}
    curl -sf --max-time 20 -G "$API" \
        --data-urlencode "q=$query" \
        -d categories=100 -d purity=100 -d sorting=random \
        -d atleast=2560x1440 -d ratios=16x9,16x10 |
    /usr/bin/python3 -c '
import json, sys
seen = set(open(sys.argv[1]).read().split()) if len(sys.argv) > 1 else set()
for w in json.load(sys.stdin)["data"]:
    if w["id"] not in seen:
        print(w["id"], w["path"]); break
' "$STATE/seen"
}

# Следующая по кругу картинка из своего пула.
pick_local() {
    local files last pick
    [ -d "$POOL" ] || return
    files=$(find "$POOL" -maxdepth 1 -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \) | sort)
    [ -n "$files" ] || return
    last=$(cat "$STATE/last-local" 2>/dev/null)
    pick=$(printf '%s\n' "$files" | awk -v last="$last" 'found {print; exit} $0 == last {found = 1}')
    [ -n "$pick" ] || pick=$(printf '%s\n' "$files" | head -n1)
    echo "$pick" > "$STATE/last-local"
    echo "$pick"
}

apply() {
    # sips приводит любой формат к PNG и ужимает до 2560 px по длинной стороне.
    sips -s format png -Z 2560 "$1" --out "$CURRENT.tmp.png" >/dev/null 2>&1 || return 1
    mv "$CURRENT.tmp.png" "$CURRENT"
    for sock in /tmp/kitty-sock-*; do
        [ -S "$sock" ] || continue
        "$KITTY" @ --to "unix:$sock" set-background-image --all --configured "$CURRENT" 2>/dev/null
    done
}

next() {
    mkdir -p "$STATE"
    touch "$STATE/seen"
    local id url file
    read -r id url < <(pick_remote)
    if [ -n "$url" ] && curl -sf --max-time 120 -o "$STATE/download" "$url" && apply "$STATE/download"; then
        echo "$id" >> "$STATE/seen"
        echo "$id $url" > "$STATE/now"
    else
        file=$(pick_local)
        [ -n "$file" ] && apply "$file" && echo "local $file" > "$STATE/now"
    fi
    rm -f "$STATE/download"
}

keep() {
    local id
    id=$(cut -d' ' -f1 "$STATE/now")
    [ "$id" = local ] && { echo "уже из пула"; return; }
    cp "$CURRENT" "$POOL/$id.png" && echo "сохранено: $POOL/$id.png"
}

case "$1" in
    next) next ;;
    keep) keep ;;
    info) cat "$STATE/now"; echo "показано с wallhaven: $(wc -l < "$STATE/seen")" ;;
    *) echo "usage: $0 next|keep|info" >&2; exit 1 ;;
esac
