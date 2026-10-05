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
# wallhaven закрыл проверкой Cloudflare, поэтому через теги.
# Дизлайк (dislike) убирает картинку из истории и из лайков, сразу листает
# дальше, а её теги пишет в DISLIKED_TAGS: каждый такой тег гасит один такой
# же из лайкнутых при поиске похожих. Нет сети — по кругу из своего пула
# dotfiles/kitty/wallpapers. Впрок держится очередь QUEUE из QUEUE_SIZE уже
# скачанных и ужатых до 2560 px в PNG картинок — следующая встаёт мгновенно,
# а очередь сама дозаполняется в фоне. Показанная картинка ложится в историю
# HISTORY под номером по порядку; позади текущей хранится KEEP_BACK, так по
# ней можно ходить назад и вперёд. Текущая копируется в
# CURRENT (на него смотрит background_image в kitty.conf, так новые окна сразу
# открываются с ней) и отправляется во все запущенные kitty через remote
# control (listen_on unix:/tmp/kitty-sock-<pid>). Та же картинка, без
# затемнения, ставится обоями рабочего стола на все экраны и фоном чатов
# Telegram (подменой его файлов фона, см. telegram()).
# Яркость — это background_tint: насколько цвет фона темы перекрывает
# картинку. Подбирается сам под каждую картинку: замеряется её средняя
# яркость L (0…1), и tint ставится такой, чтобы смесь картинки с фоном темы
# (яркость BASE_LUMA) вышла яркостью TARGET — светлые картинки глушатся
# сильнее, тёмные слабее. Клавишами меняется сам TARGET, он запоминается.
# Готовое значение пишется в TINT_CONF, его подключает kitty.conf.
#   kittywall.sh auto      новая картинка в конец истории (раз в 15 минут, LaunchAgent)
#   kittywall.sh next      вперёд по истории, с последней — новая картинка
#   kittywall.sh prev      назад по истории
#   kittywall.sh brighter  фон ярче (tint меньше на TINT_STEP)
#   kittywall.sh darker    фон темнее
#   kittywall.sh keep      лайк: сохранить текущую в пул и запомнить её теги
#   kittywall.sh dislike   дизлайк: убрать текущую и показать следующую
#   kittywall.sh fill      докачать очередь (сам зовётся в фоне после смены)
#   kittywall.sh info      что сейчас на фоне
#   kittywall.sh tg-restore  вернуть Telegram его исходный фон
#   kittywall.sh tg-refresh  перезапустить Telegram, если он не видел новый фон
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
TG="$HOME/Library/Group Containers/6N38VWS5BX.ru.keepcoder.Telegram/stable"
TG_BACKUP="$STATE/tg-backup"
# Не чаще раза в TG_RESTART_EVERY секунд Telegram перезапускается, чтобы
# увидеть новый фон.
TG_RESTART_EVERY=3600
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
DISLIKED_TAGS="$STATE/disliked-tags"
LIKED_SHARE=15
SIMILAR_SHARE=25
FLAT_MAX=0.72
QUEUE_SIZE=10
KEEP_BACK=10
# Средняя картинка (L около 0.4) при TARGET 0.15 получает tint 0.90.
TARGET_DEFAULT=0.15
# Одно нажатие сдвигает tint текущей картинки на TINT_STEP, какая бы она ни была.
TINT_STEP=0.015
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
    # Строка тега: "id имя"; одинаковые строки от разных лайков — вес, каждая
    # такая же строка из дизлайков этот вес на единицу снимает.
    [ -s "$LIKED_TAGS" ] && [ $(( RANDOM % 100 )) -lt "$SIMILAR_SHARE" ] &&
        tag=$(touch "$DISLIKED_TAGS"; awk -v n=$RANDOM '
            NR == FNR {dis[$0]++; next}
            dis[$0] > 0 {dis[$0]--; next}
            {a[++k] = $0}
            END {srand(n); if (k) print a[int(rand() * k) + 1]}' "$DISLIKED_TAGS" "$LIKED_TAGS")
    if [ -n "$tag" ]; then
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
        'BEGIN {t = (l - b > 0.01) ? (l - tg) / (l - b) : lo; if (t < lo) t = lo; if (t > hi) t = hi; printf "%.3f", t}')
    echo "background_tint $t" > "$TINT_CONF"
    for sock in /tmp/kitty-sock-*; do
        [ -S "$sock" ] || continue
        "$KITTY" @ --to "unix:$sock" load-config 2>/dev/null
    done
}

# Обои рабочего стола — картинка $1 на все экраны (на тех Spaces, что сейчас
# открыты). macOS кеширует обои по пути файла, поэтому каждый раз новое имя,
# а прошлые файлы удаляются. NSWorkspace, в отличие от System Events, не
# требует разрешения на управление другими программами.
desktop() {
    local file
    mkdir -p "$STATE/desktop"
    file="$STATE/desktop/$(date +%s)-$RANDOM.png"
    cp "$1" "$file" || return
    osascript -l JavaScript - "$file" >/dev/null 2>&1 <<'EOF'
ObjC.import("AppKit");
function run(argv) {
    var url = $.NSURL.fileURLWithPath(argv[0]);
    var screens = $.NSScreen.screens;
    for (var i = 0; i < screens.count; i++)
        $.NSWorkspace.sharedWorkspace.setDesktopImageURLForScreenOptionsError(url, screens.objectAtIndex(i), $({}), null);
}
EOF
    find "$STATE/desktop" -type f ! -path "$file" -delete
}

# Фон чатов Telegram — картинка $1. Команды или API для локальной смены фона
# у Telegram нет, поэтому подменяются его файлы. Окно чата рисует не сам фон,
# а его заранее обрезанную под окно копию в Wallpapers/telegram-local-file-
# <id>_isDark__{0,1}.png (для светлой и тёмной темы) и читает её только при
# запуске — какую именно, видно по времени последнего чтения. Заодно
# подменяется и сам фон: postbox/media/<id> (жёсткой ссылкой он же _partial)
# и его отрисовки <id>rotation0_isDark__{0,1}.png, текущий — самая свежая из
# них. Настройки ссылаются на файлы по id, базу трогать не нужно. В
# отрисовки картинка пишется целиком (JPEG до 1920 px): подгонка под их
# 710x1080 оставляла от широкой картинки узкую полосу. В сам фон — JPEG того
# же размера в пикселях, что оригинал, с добивкой нулями до прежнего размера
# файла, иначе Telegram сочтёт его недокачанным. Оригиналы один раз копируются в
# TG_BACKUP/<id>, их возвращает tg-restore. Новый фон виден после перезапуска
# Telegram.
telegram() {
    local wall id media crop f
    [ -d "$TG/Wallpapers" ] || return 0
    wall=$(ls -t "$TG/Wallpapers"/telegram-cloud-document-*_isDark__0.png 2>/dev/null | head -n1)
    crop=$(ls -tu "$TG/Wallpapers"/telegram-local-file-*_isDark__*.png 2>/dev/null | head -n1)
    [ -n "$wall" ] || return 0
    wall=${wall%_isDark__0.png}
    crop=${crop%_isDark__*.png}
    id=$(basename "$wall" | sed 's/rotation[0-9]*$//')
    media=$(ls -d "$TG"/account-*/postbox/media 2>/dev/null | head -n1)
    mkdir -p "$TG_BACKUP/$id"
    for f in "$media/$id" "$media/${id}_partial" "${wall}_isDark__0.png" "${wall}_isDark__1.png" \
             ${crop:+"${crop}_isDark__0.png" "${crop}_isDark__1.png"}; do
        [ -f "$f" ] || continue
        [ -f "$TG_BACKUP/$id/$(basename "$f")" ] || cp -p "$f" "$TG_BACKUP/$id/"
        case "$f" in
            # Отрисовки Telegram открывает как обычную картинку: туда целиком,
            # без обрезки — окно чата само заполняется ею с краёв.
            "$TG/Wallpapers/"*)
                sips -s format jpeg -s formatOptions 80 -Z 1920 "$1" --out "$f.kw.jpg" >/dev/null 2>&1 \
                    && cat "$f.kw.jpg" > "$f"
                rm -f "$f.kw.jpg" ;;
            *) tg_put "$1" "$f" "$TG_BACKUP/$id/$(basename "$f")" ;;
        esac
    done
}

# Записать картинку $1 в файл Telegram $2 по образцу оригинала $3: та же
# ширина и высота (по центру с обрезкой), JPEG, добивка нулями до размера $3.
tg_put() {
    local tmp w h iw ih size new q=85
    w=$(sips -g pixelWidth "$3" 2>/dev/null | awk '/pixelWidth/ {print $2}')
    h=$(sips -g pixelHeight "$3" 2>/dev/null | awk '/pixelHeight/ {print $2}')
    iw=$(sips -g pixelWidth "$1" 2>/dev/null | awk '/pixelWidth/ {print $2}')
    ih=$(sips -g pixelHeight "$1" 2>/dev/null | awk '/pixelHeight/ {print $2}')
    [ -n "$w" ] && [ -n "$h" ] && [ -n "$iw" ] && [ -n "$ih" ] || return 1
    size=$(stat -f %z "$3")
    tmp=$(mktemp -d) || return
    while :; do
        # Сперва вписать по меньшей стороне, потом обрезать лишнее по центру.
        if [ $((iw * h)) -gt $((ih * w)) ]; then
            sips -s format jpeg -s formatOptions "$q" --resampleHeight "$h" "$1" --out "$tmp/r.jpg" >/dev/null 2>&1
        else
            sips -s format jpeg -s formatOptions "$q" --resampleWidth "$w" "$1" --out "$tmp/r.jpg" >/dev/null 2>&1
        fi
        sips -c "$h" "$w" "$tmp/r.jpg" --out "$tmp/new.jpg" >/dev/null 2>&1 || break
        new=$(stat -f %z "$tmp/new.jpg")
        [ "$new" -le "$size" ] || [ "$q" -le 30 ] && break
        q=$((q - 10))
    done
    if [ -f "$tmp/new.jpg" ] && [ "$new" -le "$size" ]; then
        # cat в существующий файл, а не mv: жёсткая ссылка _partial сохраняется.
        { cat "$tmp/new.jpg"; head -c $((size - new)) /dev/zero; } > "$tmp/out"
        cat "$tmp/out" > "$2"
    fi
    rm -rf "$tmp"
}

# Вернуть Telegram все исходные фоны из TG_BACKUP.
tg_restore() {
    local dir id media f
    media=$(ls -d "$TG"/account-*/postbox/media 2>/dev/null | head -n1)
    for dir in "$TG_BACKUP"/*/; do
        [ -d "$dir" ] || continue
        id=$(basename "$dir")
        for f in "$dir"*; do
            case "$f" in
                *_isDark__*) cat "$f" > "$TG/Wallpapers/$(basename "$f")" ;;
                *) cat "$f" > "$media/$(basename "$f")" ;;
            esac
        done
        echo "вернул фон $id"
    done
}

# Перезапустить Telegram, чтобы он показал новый фон. Готовую картинку фона
# он держит в памяти и файл читает только при запуске, а снаружи эту память
# не сбросить (hardened runtime, SIP). Перезапуск только если: Telegram
# запущен, не на переднем плане, обрезанная копия фона изменилась после того,
# как он её прочитал (mtime новее atime), и с прошлого перезапуска прошло
# TG_RESTART_EVERY. Telegram закрывается и открывается через NSWorkspace и
# NSRunningApplication — им, в отличие от osascript "quit app", не нужно
# разрешение на управление другими программами. open -g не выводит его окно
# на передний план.
tg_refresh() {
    local crop last now
    crop=$(ls -tu "$TG/Wallpapers"/telegram-local-file-*_isDark__*.png 2>/dev/null | head -n1)
    [ -n "$crop" ] || return 0
    [ "$(stat -f %m "$crop")" -gt "$(stat -f %a "$crop")" ] || return 0
    now=$(date +%s)
    last=$(cat "$STATE/tg-restarted" 2>/dev/null || echo 0)
    [ $((now - last)) -ge "$TG_RESTART_EVERY" ] || return 0
    osascript -l JavaScript >/dev/null 2>&1 <<'EOF' || return 0
ObjC.import("AppKit");
var id = "ru.keepcoder.Telegram";
var apps = $.NSRunningApplication.runningApplicationsWithBundleIdentifier(id);
var front = $.NSWorkspace.sharedWorkspace.frontmostApplication;
if (apps.count == 0 || (!front.isNil() && front.bundleIdentifier.js == id))
    throw "skip";
apps.objectAtIndex(0).terminate;
EOF
    # Ждать выхода по pgrep: свойство terminated в osascript не обновляется.
    for _ in $(seq 150); do pgrep -xq Telegram || break; sleep 0.1; done
    echo "$now" > "$STATE/tg-restarted"
    open -g -b ru.keepcoder.Telegram
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
    desktop "$CURRENT" &
    telegram "$CURRENT" &
    TG_PID=$!
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

# Ближайший существующий номер истории после (next) или до (prev) $1:
# после дизлайка в нумерации бывают дыры.
near() {
    ls "$HISTORY" | sed -n 's/^0*\([0-9][0-9]*\)\.png$/\1/p' |
        awk -v p="$1" -v dir="$2" '
            dir == "next" && $1 > p && (r == "" || $1 < r) {r = $1}
            dir == "prev" && $1 < p && (r == "" || $1 > r) {r = $1}
            END {print r}'
}

next() {
    local n
    n=$(near "$(pos)" next)
    if [ -n "$n" ]; then show "$n"; else fresh; fi
}

prev() {
    local n
    n=$(near "$(pos)" prev)
    [ -n "$n" ] && show "$n"
}

# Сдвинуть TARGET так, чтобы tint текущей картинки ушёл на $1 (из формулы в
# retint: TARGET меняется на −Δt·(L − BASE)), и пересчитать tint.
target() {
    local cur l
    cur=$(cat "$STATE/target" 2>/dev/null || echo "$TARGET_DEFAULT")
    l=$(cat "$STATE/luma" 2>/dev/null || echo 0.4)
    awk -v c="$cur" -v dt="$1" -v l="$l" -v b="$BASE_LUMA" 'BEGIN {k = l - b; if (k < 0.05) k = 0.05; v = c - dt * k; if (v < 0.02) v = 0.02; if (v > 0.6) v = 0.6; printf "%.3f\n", v}' > "$STATE/target"
    retint
}

# Теги картинки wallhaven $1 строками "id имя".
tags() {
    curl -sf --max-time 20 -A "Mozilla/5.0 (Macintosh) kittywall" "https://wallhaven.cc/api/v1/w/$1" |
        /usr/bin/python3 -c '
import json, sys
for t in json.load(sys.stdin)["data"]["tags"]:
    print(t["id"], t["name"])
'
}

notify() {
    echo "$1"
    osascript -e "display notification \"$1\" with title \"kittywall\"" 2>/dev/null
}

dislike() {
    local n id url
    n=$(pos)
    read -r id url _ < "$(slot "$n").txt"
    case "$id" in
        liked) rm -f "$url" ;;
        local) ;;
        *) rm -f "$POOL/$id.png"; tags "$id" >> "$DISLIKED_TAGS" ;;
    esac
    rm -f "$(slot "$n")".*
    notify "дизлайк: больше не покажу"
    next
}

keep() {
    local id url msg
    read -r id url _ < "$(slot "$(pos)").txt"
    if [ "$id" = local ] || [ "$id" = liked ] || [ -f "$POOL/$id.png" ]; then
        msg="уже в лайках"
    elif cp "$CURRENT" "$POOL/$id.png"; then
        # Теги картинки — для поиска похожих.
        tags "$id" >> "$LIKED_TAGS"
        msg="лайк: $(ls "$POOL" | wc -l | tr -d ' ') в коллекции"
    else
        msg="не сохранилось: нет /Volumes/pr?"
    fi
    notify "$msg"
}

mkdir -p "$HISTORY" "$QUEUE"
# Нажатия подряд не должны менять фон разом: второе ждёт первое. Докачка
# очереди идёт мимо этого замка, у неё свой.
if [ "$1" != fill ] && [ "$1" != info ] && [ "$1" != tg-restore ]; then
    for _ in $(seq 100); do mkdir "$STATE/lock" 2>/dev/null && break; sleep 0.3; done
    trap 'rmdir "$STATE/lock" 2>/dev/null' EXIT
fi
touch "$STATE/seen"
[ -f "$TINT_CONF" ] || echo "background_tint 0.90" > "$TINT_CONF"

case "$1" in
    # Сперва дождаться фоновой подмены фона Telegram из show().
    auto) fresh; [ -n "$TG_PID" ] && wait "$TG_PID"; tg_refresh ;;
    next) next ;;
    prev) prev ;;
    brighter) target "-$TINT_STEP" ;;
    darker) target "$TINT_STEP" ;;
    keep) keep ;;
    dislike) dislike ;;
    fill) fill ;;
    tg-restore) tg_restore ;;
    tg-refresh) tg_refresh ;;
    info)
        echo "$(cat "$(slot "$(pos)").txt" 2>/dev/null)  [$(pos) из $(last)]"
        echo "яркость картинки $(cat "$STATE/luma" 2>/dev/null), цель $(cat "$STATE/target" 2>/dev/null || echo "$TARGET_DEFAULT"), $(cat "$TINT_CONF")"
        echo "в очереди: $(ls "$QUEUE" | grep -c '\.png$'), показано с wallhaven: $(wc -l < "$STATE/seen")" ;;
    *) echo "usage: $0 auto|next|prev|brighter|darker|keep|dislike|fill|info|tg-restore|tg-refresh" >&2; exit 1 ;;
esac
