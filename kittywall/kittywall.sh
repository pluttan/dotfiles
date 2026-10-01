#!/bin/bash
# kittywall — каждый раз новый фон kitty на маке. Картинка берётся случайной
# с wallhaven.cc по одной из тем QUERIES; уже показанные запоминаются в seen и
# второй раз не попадаются. Нет сети — по кругу из своего пула
# dotfiles/kitty/wallpapers. Впрок держится очередь QUEUE из QUEUE_SIZE уже
# скачанных и ужатых до 2560 px в PNG картинок — следующая встаёт мгновенно,
# а очередь сама дозаполняется в фоне. Показанная картинка ложится в историю
# HISTORY под номером по порядку; позади текущей хранится KEEP_BACK, так по
# ней можно ходить назад и вперёд. Текущая копируется в
# CURRENT (на него смотрит background_image в kitty.conf, так новые окна сразу
# открываются с ней) и отправляется во все запущенные kitty через remote
# control (listen_on unix:/tmp/kitty-sock-<pid>).
# Яркость — это background_tint: насколько цвет фона темы перекрывает
# картинку. Подбирается сам под каждую картинку: замеряется её средняя
# яркость L (0…1), и tint ставится такой, чтобы смесь картинки с фоном темы
# (яркость BASE_LUMA) вышла яркостью TARGET — светлые картинки глушатся
# сильнее, тёмные слабее. Клавишами меняется сам TARGET, он запоминается.
# Готовое значение пишется в TINT_CONF, его подключает kitty.conf.
#   kittywall.sh auto      новая картинка в конец истории (раз в 15 минут, LaunchAgent)
#   kittywall.sh next      вперёд по истории, с последней — новая картинка
#   kittywall.sh prev      назад по истории
#   kittywall.sh brighter  фон ярче (TARGET выше на TARGET_STEP)
#   kittywall.sh darker    фон темнее
#   kittywall.sh keep      понравилась — сохранить текущую в пул
#   kittywall.sh fill      докачать очередь (сам зовётся в фоне после смены)
#   kittywall.sh info      что сейчас на фоне
# Signed: pluttan

# kitty запускает скрипт с локалью пользователя, а в ru_RU awk пишет дробь
# через запятую (0,75) — kitty такую строку не принимает.
export LC_ALL=C

POOL=/Volumes/pr/dotfiles/kitty/wallpapers
STATE="$HOME/.local/share/kittywall"
HISTORY="$STATE/history"
QUEUE="$STATE/queue"
CURRENT="$STATE/current.png"
TINT_CONF="$STATE/tint.conf"
KITTY=/Applications/kitty.app/Contents/MacOS/kitty
API=https://wallhaven.cc/api/v1/search
QUERIES=("landscape" "mountains" "lighthouse" "pixel art landscape" "night city" "forest" "sea" "digital art landscape")
QUEUE_SIZE=10
KEEP_BACK=10
# Средняя картинка (L около 0.4) при TARGET 0.15 получает tint 0.90.
TARGET_DEFAULT=0.15
TARGET_STEP=0.015
# Яркость #1e1e2e — base из Catppuccin Mocha, им kitty и подмешивает tint.
BASE_LUMA=0.125
TINT_MIN=0.20
TINT_MAX=0.97

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

# Средняя яркость картинки $1 от 0 до 1. sips ужимает её до 32×32 в BMP
# (24 бита, без сжатия), а его пиксели уже читаются без сторонних библиотек.
luma() {
    sips -s format bmp -z 32 32 "$1" --out "$STATE/luma.bmp" >/dev/null 2>&1 || return 1
    /usr/bin/python3 -c '
import struct, sys
b = open(sys.argv[1], "rb").read()
off, = struct.unpack_from("<I", b, 10)
w, h = struct.unpack_from("<ii", b, 18)
bpp, = struct.unpack_from("<H", b, 28)
step, row = bpp // 8, (w * bpp // 8 + 3) & ~3
total = 0
for y in range(abs(h)):
    for x in range(w):
        bl, g, r = b[off + y * row + x * step: off + y * row + x * step + 3]
        total += 0.299 * r + 0.587 * g + 0.114 * bl
print("%.3f" % (total / (w * abs(h)) / 255))
' "$STATE/luma.bmp"
    rm -f "$STATE/luma.bmp"
}

# tint под текущую картинку и TARGET: из L·(1−t) + BASE·t = TARGET.
# Записывает TINT_CONF и перечитывает конфиг во всех kitty.
retint() {
    local target l t
    target=$(cat "$STATE/target" 2>/dev/null || echo "$TARGET_DEFAULT")
    l=$(cat "$STATE/luma" 2>/dev/null || echo 0.4)
    t=$(awk -v l="$l" -v b="$BASE_LUMA" -v tg="$target" -v lo="$TINT_MIN" -v hi="$TINT_MAX" \
        'BEGIN {t = (l - b > 0.01) ? (l - tg) / (l - b) : lo; if (t < lo) t = lo; if (t > hi) t = hi; printf "%.2f", t}')
    echo "background_tint $t" > "$TINT_CONF"
    for sock in /tmp/kitty-sock-*; do
        [ -S "$sock" ] || continue
        "$KITTY" @ --to "unix:$sock" load-config 2>/dev/null
    done
}

# Отправить картинку из истории под номером $1 во все kitty.
show() {
    cp "$(slot "$1").png" "$CURRENT.tmp" && mv "$CURRENT.tmp" "$CURRENT" || return 1
    echo "$1" > "$STATE/pos"
    # Яркость считается один раз и лежит рядом с картинкой в истории.
    [ -s "$(slot "$1").luma" ] || luma "$CURRENT" > "$(slot "$1").luma"
    cp "$(slot "$1").luma" "$STATE/luma" 2>/dev/null || rm -f "$STATE/luma"
    # Сперва новый tint, потом картинка: яркая не мелькнёт со старым.
    retint
    for sock in /tmp/kitty-sock-*; do
        [ -S "$sock" ] || continue
        "$KITTY" @ --to "unix:$sock" set-background-image --all --configured "$CURRENT" 2>/dev/null
    done
}

# Скачать с wallhaven одну непоказанную картинку в $1.png, рядом $1.txt
# ("id url") и $1.luma. Не вышло (нет сети, сбой) — код возврата 1.
download() {
    local id url
    read -r id url < <(pick_remote)
    [ -n "$url" ] || return 1
    curl -sf --max-time 120 -o "$1.download" "$url" || { rm -f "$1.download"; return 1; }
    # sips приводит любой формат к PNG и ужимает до 2560 px по длинной стороне.
    sips -s format png -Z 2560 "$1.download" --out "$1.png" >/dev/null 2>&1
    local ok=$?
    rm -f "$1.download"
    [ $ok = 0 ] || { rm -f "$1.png"; return 1; }
    echo "$id" >> "$STATE/seen"
    echo "$id $url" > "$1.txt"
    luma "$1.png" > "$1.luma" || rm -f "$1.luma"
}

# Докачать очередь до QUEUE_SIZE. Второй экземпляр сразу выходит; замок
# старше 10 минут считается брошенным упавшим процессом.
fill() {
    find "$STATE/filllock" -maxdepth 0 -mmin +10 -exec rmdir {} \; 2>/dev/null
    mkdir "$STATE/filllock" 2>/dev/null || return 0
    trap 'rmdir "$STATE/filllock" 2>/dev/null' EXIT
    local name
    while [ "$(ls "$QUEUE" | grep -c '\.png$')" -lt "$QUEUE_SIZE" ]; do
        # Имя по времени — очередь берётся по порядку скачивания.
        name=$(printf '%010d-%05d' "$(date +%s)" "$RANDOM")
        download "$QUEUE/.part" || break
        for ext in txt luma png; do
            [ -f "$QUEUE/.part.$ext" ] && mv "$QUEUE/.part.$ext" "$QUEUE/$name.$ext"
        done
    done
}

# Новая картинка в конец истории и на экран: первая из очереди, пусто — качаем
# сейчас, нет сети — из своего пула. Потом очередь дозаполняется в фоне.
fresh() {
    local n l q file
    l=$(last)
    n=$(( ${l:-0} + 1 ))
    q=$(ls "$QUEUE" | sed -n 's/\.png$//p' | sort | head -n1)
    if [ -n "$q" ]; then
        for ext in txt luma png; do
            [ -f "$QUEUE/$q.$ext" ] && mv "$QUEUE/$q.$ext" "$(slot "$n").$ext"
        done
    elif ! download "$(slot "$n")"; then
        file=$(pick_local)
        [ -n "$file" ] || return 1
        sips -s format png -Z 2560 "$file" --out "$(slot "$n").png" >/dev/null 2>&1 || return 1
        echo "local $file" > "$(slot "$n").txt"
    fi
    show "$n"
    # Позади текущей держим KEEP_BACK картинок, что старше — удаляем.
    ls "$HISTORY" | sed -n 's/^0*\([0-9][0-9]*\)\.png$/\1/p' |
        while read -r old; do
            [ "$old" -lt $(( n - KEEP_BACK )) ] && rm -f "$(slot "$old")".*
        done
    nohup /bin/bash "$0" fill >/dev/null 2>&1 &
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

# Сдвинуть TARGET на $1 и пересчитать tint текущей картинки.
target() {
    local cur
    cur=$(cat "$STATE/target" 2>/dev/null || echo "$TARGET_DEFAULT")
    awk -v c="$cur" -v d="$1" 'BEGIN {v = c + d; if (v < 0.02) v = 0.02; if (v > 0.6) v = 0.6; printf "%.3f\n", v}' > "$STATE/target"
    retint
}

keep() {
    local id
    id=$(cut -d' ' -f1 "$(slot "$(pos)").txt")
    [ "$id" = local ] && { echo "уже из пула"; return; }
    cp "$CURRENT" "$POOL/$id.png" && echo "сохранено: $POOL/$id.png"
}

mkdir -p "$HISTORY" "$QUEUE"
# Нажатия подряд не должны менять фон разом: второе ждёт первое. Докачка
# очереди идёт мимо этого замка, у неё свой.
if [ "$1" != fill ] && [ "$1" != info ]; then
    for _ in $(seq 100); do mkdir "$STATE/lock" 2>/dev/null && break; sleep 0.3; done
    trap 'rmdir "$STATE/lock" 2>/dev/null' EXIT
fi
touch "$STATE/seen"
[ -f "$TINT_CONF" ] || echo "background_tint 0.90" > "$TINT_CONF"

case "$1" in
    auto) fresh ;;
    next) next ;;
    prev) prev ;;
    brighter) target "$TARGET_STEP" ;;
    darker) target "-$TARGET_STEP" ;;
    keep) keep ;;
    fill) fill ;;
    info)
        echo "$(cat "$(slot "$(pos)").txt" 2>/dev/null)  [$(pos) из $(last)]"
        echo "яркость картинки $(cat "$STATE/luma" 2>/dev/null), цель $(cat "$STATE/target" 2>/dev/null || echo "$TARGET_DEFAULT"), $(cat "$TINT_CONF")"
        echo "в очереди: $(ls "$QUEUE" | grep -c '\.png$'), показано с wallhaven: $(wc -l < "$STATE/seen")" ;;
    *) echo "usage: $0 auto|next|prev|brighter|darker|keep|fill|info" >&2; exit 1 ;;
esac
