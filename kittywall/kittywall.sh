#!/bin/bash
# kittywall — каждый раз новый фон kitty на маке. Картинка берётся с
# wallhaven.cc по случайной теме из THEMES: из верхних TOP_SHARE страниц
# выдачи, отсортированной по числу добавлений в избранное, — так мусора почти
# нет. Однотонные (логотип или мелкая картинка на ровном фоне: больше
# FLAT_MAX пикселей близки к основному цвету) отсеиваются. Уже показанные
# запоминаются в seen и второй раз не попадаются.
# Лайк (keep) кладёт картинку в свой пул и запоминает её теги в LIKED_TAGS:
# LIKED_SHARE процентов смен показывают случайную лайкнутую, а SIMILAR_SHARE
# процентов новых ищутся по случайному тегу лайкнутых — чем у большего числа
# лайков тег есть, тем чаще он выпадает. Поиск похожих напрямую (like:id)
# wallhaven закрыл проверкой Cloudflare, поэтому через теги. Нет сети — по кругу из своего пула
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
#   kittywall.sh keep      лайк: сохранить текущую в пул и запомнить её теги
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
# У anime в SFW-выдаче остаётся фансервис — его теги исключаются из запроса.
NO_ECCHI='-ecchi -cleavage -bikini -swimwear -lingerie -panties -underwear -thighs -stockings -boobs -ass -"big boobs" -"thigh-highs" -pantyhose -"bunny girl" -"no bra" -sideboob -underboob'
# Тема: имя|запрос|категории (general, anime, people)|минимальный размер.
THEMES=(
    "lofi|lofi|110|1920x1080"
    "anime-scenery|anime scenery|110|1920x1080"
    "anime|$NO_ECCHI|010|2560x1440"
    "cold|winter|110|2560x1440"
    "nature|nature|100|2560x1440"
    "vaporwave|vaporwave|110|1920x1080"
    "catppuccin|catppuccin|110|1920x1080"
)
TOP_SHARE=30
LIKED_TAGS="$STATE/liked-tags"
LIKED_SHARE=15
SIMILAR_SHARE=25
FLAT_MAX=0.72
QUEUE_SIZE=10
KEEP_BACK=10
# Средняя картинка (L около 0.4) при TARGET 0.15 получает tint 0.90.
TARGET_DEFAULT=0.15
TARGET_STEP=0.015
# Яркость #1e1e2e — base из Catppuccin Mocha, им kitty и подмешивает tint.
BASE_LUMA=0.125
TINT_MIN=0.20
TINT_MAX=0.97

# Страница поиска wallhaven по теме, отсортированная по избранному.
search() {
    local q=$1 cats=$2 size=$3 page=$4
    curl -sf --max-time 20 -A "Mozilla/5.0 (Macintosh) kittywall" -G "$API" \
        --data-urlencode "q=$q" -d categories="$cats" -d purity=100 \
        -d sorting=favorites -d order=desc -d page="$page" \
        -d atleast="$size" -d ratios=16x9,16x10
}

# Случайная непоказанная картинка по случайной теме: печатает "id url тема"
# или ничего. Число страниц темы запоминается на неделю в PAGES.
pick_remote() {
    local name q cats size pages page cache tag
    if [ -s "$LIKED_TAGS" ] && [ $(( RANDOM % 100 )) -lt "$SIMILAR_SHARE" ]; then
        # Строка тега: "id имя"; одинаковые строки от разных лайков — вес.
        tag=$(awk -v n=$RANDOM 'NR == 1 {srand(n)} {a[NR] = $0} END {print a[int(rand() * NR) + 1]}' "$LIKED_TAGS")
        name="tag-${tag%% *}" q="id:${tag%% *}" cats=111 size=1920x1080
    else
        IFS='|' read -r name q cats size <<< "${THEMES[RANDOM % ${#THEMES[@]}]}"
    fi
    cache="$STATE/pages/$name"
    mkdir -p "$STATE/pages"
    if [ -n "$(find "$cache" -mtime -7 2>/dev/null)" ]; then
        pages=$(cat "$cache")
    else
        pages=$(search "$q" "$cats" "$size" 1 | /usr/bin/python3 -c 'import json, sys; print(json.load(sys.stdin)["meta"]["last_page"])') || return
        echo "$pages" > "$cache"
    fi
    page=$(( RANDOM % ( pages * TOP_SHARE / 100 > 0 ? pages * TOP_SHARE / 100 : 1 ) + 1 ))
    search "$q" "$cats" "$size" "$page" |
    /usr/bin/python3 -c '
import json, random, sys
seen = set(open(sys.argv[1]).read().split())
data = [w for w in json.load(sys.stdin)["data"] if w["id"] not in seen]
if data:
    w = random.choice(data)
    print(w["id"], w["path"], sys.argv[2])
' "$STATE/seen" "$name"
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

# В LIKED_SHARE процентах случаев — случайная лайкнутая из пула, только не та,
# что сейчас на экране. Иначе ничего.
pick_liked() {
    local now
    [ -d "$POOL" ] && [ $(( RANDOM % 100 )) -lt "$LIKED_SHARE" ] || return
    now=$(cut -d' ' -f2 "$(slot "$(pos)").txt" 2>/dev/null)
    find "$POOL" -maxdepth 1 -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \) |
        grep -vxF "$now" | awk -v n=$RANDOM 'NR == 1 {srand(n)} {a[NR] = $0} END {if (NR) print a[int(rand() * NR) + 1]}'
}

# Номер текущей картинки в истории и последний номер (0, если истории нет).
pos()  { cat "$STATE/pos" 2>/dev/null || echo 0; }
last() { ls "$HISTORY" 2>/dev/null | sed -n 's/^0*\([0-9][0-9]*\)\.png$/\1/p' | sort -n | tail -n1; }
slot() { printf '%s/%06d' "$HISTORY" "$1"; }

# Средняя яркость картинки $1 и доля пикселей, близких к её основному цвету
# (оба от 0 до 1). sips ужимает картинку до 32×32 в BMP (24 бита, без
# сжатия), а его пиксели уже читаются без сторонних библиотек.
measure() {
    local bmp
    bmp=$(mktemp "$STATE/measure.XXXXXX") || return 1
    sips -s format bmp -z 32 32 "$1" --out "$bmp" >/dev/null 2>&1 || { rm -f "$bmp"; return 1; }
    /usr/bin/python3 -c '
import struct, sys
b = open(sys.argv[1], "rb").read()
off, = struct.unpack_from("<I", b, 10)
w, h = struct.unpack_from("<ii", b, 18)
bpp, = struct.unpack_from("<H", b, 28)
step, row = bpp // 8, (w * bpp // 8 + 3) & ~3
px = [tuple(b[off + y * row + x * step: off + y * row + x * step + 3])
      for y in range(abs(h)) for x in range(w)]
luma = sum(0.299 * r + 0.587 * g + 0.114 * bl for bl, g, r in px) / len(px) / 255
# Основной цвет — самая частая ячейка по 8 оттенков на канал; близкие к нему —
# те, что отстоят от её середины меньше чем на 28 из 255.
cells = {}
for c in px:
    k = tuple(v >> 3 for v in c)
    cells[k] = cells.get(k, 0) + 1
dom = [v * 8 + 4 for v in max(cells, key=cells.get)]
near = sum(1 for c in px if sum((a - d) ** 2 for a, d in zip(c, dom)) < 28 * 28)
print("%.3f %.3f" % (luma, near / len(px)))
' "$bmp"
    rm -f "$bmp"
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
    [ -s "$(slot "$1").luma" ] || measure "$CURRENT" | cut -d' ' -f1 > "$(slot "$1").luma"
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
    local id url theme tries
    for tries in 1 2 3 4 5; do
        read -r id url theme < <(pick_remote)
        [ -n "$url" ] || return 1
        fetch "$1" "$id" "$url" "$theme" && return 0
    done
    return 1
}

# Одна попытка download: скачать, ужать, отсеять однотонную.
fetch() {
    local id=$2 url=$3 theme=$4 m
    curl -sf --max-time 120 -o "$1.download" "$url" || { rm -f "$1.download"; return 1; }
    # sips приводит любой формат к PNG и ужимает до 2560 px по длинной стороне.
    sips -s format png -Z 2560 "$1.download" --out "$1.png" >/dev/null 2>&1
    local ok=$?
    rm -f "$1.download"
    [ $ok = 0 ] || { rm -f "$1.png"; return 1; }
    echo "$id" >> "$STATE/seen"
    m=$(measure "$1.png")
    if awk -v f="${m#* }" -v max="$FLAT_MAX" 'BEGIN {exit !(f > max)}'; then
        rm -f "$1.png"
        return 1
    fi
    echo "${m% *}" > "$1.luma"
    echo "$id $url $theme" > "$1.txt"
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
    file=$(pick_liked)
    if [ -n "$file" ]; then
        sips -s format png -Z 2560 "$file" --out "$(slot "$n").png" >/dev/null 2>&1 || return 1
        echo "liked $file" > "$(slot "$n").txt"
    elif [ -n "$q" ]; then
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
    local id url msg
    read -r id url _ < "$(slot "$(pos)").txt"
    if [ "$id" = local ] || [ "$id" = liked ] || [ -f "$POOL/$id.png" ]; then
        msg="уже в лайках"
    elif cp "$CURRENT" "$POOL/$id.png"; then
        # Теги картинки — для поиска похожих.
        curl -sf --max-time 20 -A "Mozilla/5.0 (Macintosh) kittywall" "https://wallhaven.cc/api/v1/w/$id" |
            /usr/bin/python3 -c '
import json, sys
for t in json.load(sys.stdin)["data"]["tags"]:
    print(t["id"], t["name"])
' >> "$LIKED_TAGS"
        msg="лайк: $(ls "$POOL" | wc -l | tr -d ' ') в коллекции"
    else
        msg="не сохранилось: нет /Volumes/pr?"
    fi
    echo "$msg"
    osascript -e "display notification \"$msg\" with title \"kittywall\"" 2>/dev/null
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
