#!/bin/bash
# kittywall — каждый раз новый фон kitty на маке. Картинка берётся случайной
# с wallhaven.cc по одной из тем QUERIES; уже показанные запоминаются в seen и
# второй раз не попадаются. Нет сети — по кругу из своего пула
# dotfiles/kitty/wallpapers. Каждая показанная картинка, ужатая до 2560 px в
# PNG, ложится в историю HISTORY под номером по порядку (хранится KEEP_LAST
# последних), так по ней можно ходить назад и вперёд. Текущая копируется в
# CURRENT (на него смотрит background_image в kitty.conf, так новые окна сразу
# открываются с ней) и отправляется во все запущенные kitty через remote
# control (listen_on unix:/tmp/kitty-sock-<pid>).
# Яркость — это background_tint: насколько цвет фона темы перекрывает
# картинку. Значение живёт в TINT_CONF, его подключает kitty.conf.
#   kittywall.sh auto      новая картинка в конец истории (раз в 15 минут, LaunchAgent)
#   kittywall.sh next      вперёд по истории, с последней — новая картинка
#   kittywall.sh prev      назад по истории
#   kittywall.sh brighter  картинка ярче (tint меньше на TINT_STEP)
#   kittywall.sh darker    картинка темнее
#   kittywall.sh keep      понравилась — сохранить текущую в пул
#   kittywall.sh info      что сейчас на фоне
# Signed: pluttan

# kitty запускает скрипт с локалью пользователя, а в ru_RU awk пишет дробь
# через запятую (0,75) — kitty такую строку не принимает.
export LC_ALL=C

POOL=/Volumes/pr/dotfiles/kitty/wallpapers
STATE="$HOME/.local/share/kittywall"
HISTORY="$STATE/history"
CURRENT="$STATE/current.png"
TINT_CONF="$STATE/tint.conf"
KITTY=/Applications/kitty.app/Contents/MacOS/kitty
API=https://wallhaven.cc/api/v1/search
QUERIES=("landscape" "mountains" "lighthouse" "pixel art landscape" "night city" "forest" "sea" "digital art landscape")
KEEP_LAST=30
TINT_DEFAULT=0.90
TINT_STEP=0.05

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
seen = set(open(sys.argv[1]).read().split())
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

# Номер текущей картинки в истории и последний номер (0, если истории нет).
pos()  { cat "$STATE/pos" 2>/dev/null || echo 0; }
last() { ls "$HISTORY" 2>/dev/null | sed -n 's/^0*\([0-9][0-9]*\)\.png$/\1/p' | sort -n | tail -n1; }
slot() { printf '%s/%06d' "$HISTORY" "$1"; }

# Отправить картинку из истории под номером $1 во все kitty.
show() {
    cp "$(slot "$1").png" "$CURRENT.tmp" && mv "$CURRENT.tmp" "$CURRENT" || return 1
    echo "$1" > "$STATE/pos"
    for sock in /tmp/kitty-sock-*; do
        [ -S "$sock" ] || continue
        "$KITTY" @ --to "unix:$sock" set-background-image --all --configured "$CURRENT" 2>/dev/null
    done
}

# Новая картинка в конец истории и на экран.
fresh() {
    local id url file n l
    l=$(last)
    n=$(( ${l:-0} + 1 ))
    read -r id url < <(pick_remote)
    if [ -n "$url" ] && curl -sf --max-time 120 -o "$STATE/download" "$url"; then
        file="$STATE/download"
    else
        id=local url=$(pick_local)
        file=$url
    fi
    [ -n "$file" ] || return 1
    # sips приводит любой формат к PNG и ужимает до 2560 px по длинной стороне.
    sips -s format png -Z 2560 "$file" --out "$(slot "$n").png" >/dev/null 2>&1 || return 1
    rm -f "$STATE/download"
    echo "$id $url" > "$(slot "$n").txt"
    [ "$id" = local ] || echo "$id" >> "$STATE/seen"
    show "$n"
    # Старше KEEP_LAST последних — удаляем.
    ls "$HISTORY" | sed -n 's/\.png$//p' | sort -n |
        awk -v k="$KEEP_LAST" '{a[NR] = $0} END {for (i = 1; i <= NR - k; i++) print a[i]}' |
        while read -r old; do rm -f "$HISTORY/$old.png" "$HISTORY/$old.txt"; done
}

next() {
    local n
    n=$(( $(pos) + 1 ))
    if [ -f "$(slot "$n").png" ]; then show "$n"; else fresh; fi
}

prev() {
    local n
    n=$(( $(pos) - 1 ))
    [ -f "$(slot "$n").png" ] && show "$n"
}

# Сдвинуть background_tint на $1 и перечитать конфиг во всех kitty.
tint() {
    local cur new
    cur=$(awk '{print $2}' "$TINT_CONF" 2>/dev/null | tr , .)
    new=$(awk -v c="${cur:-$TINT_DEFAULT}" -v d="$1" 'BEGIN {v = c + d; if (v < 0) v = 0; if (v > 1) v = 1; printf "%.2f", v}')
    echo "background_tint $new" > "$TINT_CONF"
    for sock in /tmp/kitty-sock-*; do
        [ -S "$sock" ] || continue
        "$KITTY" @ --to "unix:$sock" load-config 2>/dev/null
    done
}

keep() {
    local id
    id=$(cut -d' ' -f1 "$(slot "$(pos)").txt")
    [ "$id" = local ] && { echo "уже из пула"; return; }
    cp "$CURRENT" "$POOL/$id.png" && echo "сохранено: $POOL/$id.png"
}

mkdir -p "$HISTORY"
# Нажатия подряд не должны качать две картинки разом: второе ждёт первое.
for _ in $(seq 100); do mkdir "$STATE/lock" 2>/dev/null && break; sleep 0.3; done
trap 'rmdir "$STATE/lock" 2>/dev/null' EXIT
touch "$STATE/seen"
[ -f "$TINT_CONF" ] || echo "background_tint $TINT_DEFAULT" > "$TINT_CONF"

case "$1" in
    auto) fresh ;;
    next) next ;;
    prev) prev ;;
    brighter) tint "-$TINT_STEP" ;;
    darker) tint "$TINT_STEP" ;;
    keep) keep ;;
    info)
        echo "$(cat "$(slot "$(pos)").txt" 2>/dev/null)  [$(pos) из $(last)]"
        cat "$TINT_CONF"
        echo "показано с wallhaven: $(wc -l < "$STATE/seen")" ;;
    *) echo "usage: $0 auto|next|prev|brighter|darker|keep|info" >&2; exit 1 ;;
esac
