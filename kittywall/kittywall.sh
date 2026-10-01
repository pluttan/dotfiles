#!/bin/bash
# kittywall — смена фона kitty на маке по кругу из папки dotfiles/kitty/wallpapers.
# Очередная картинка копируется в CURRENT (на него смотрит background_image в
# kitty.conf, так новые окна сразу открываются с ней) и отправляется во все
# запущенные kitty через remote control (listen_on unix:/tmp/kitty-sock-<pid>).
#   kittywall.sh next   следующая картинка (её раз в 15 минут зовёт LaunchAgent)
#   kittywall.sh list   какие картинки в круге и какая сейчас
# Signed: pluttan

POOL=/Volumes/pr/dotfiles/kitty/wallpapers
STATE="$HOME/.local/share/kittywall"
CURRENT="$STATE/current.png"
KITTY=/Applications/kitty.app/Contents/MacOS/kitty

pool() {
    find "$POOL" -maxdepth 1 -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \) | sort
}

next() {
    # Внешний SSD не подключён — оставляем текущий фон как есть.
    [ -d "$POOL" ] || exit 0
    mkdir -p "$STATE"
    local files last pick
    files=$(pool)
    [ -n "$files" ] || exit 0
    last=$(cat "$STATE/last" 2>/dev/null)
    # Берём файл после последнего показанного; с конца списка — снова первый.
    pick=$(printf '%s\n' "$files" | awk -v last="$last" 'found {print; exit} $0 == last {found = 1}')
    [ -n "$pick" ] || pick=$(printf '%s\n' "$files" | head -n1)
    cp "$pick" "$CURRENT.tmp" && mv "$CURRENT.tmp" "$CURRENT"
    echo "$pick" > "$STATE/last"
    for sock in /tmp/kitty-sock-*; do
        [ -S "$sock" ] || continue
        "$KITTY" @ --to "unix:$sock" set-background-image --all --configured "$CURRENT" 2>/dev/null
    done
}

case "$1" in
    next) next ;;
    list) pool; echo "сейчас: $(cat "$STATE/last" 2>/dev/null)" ;;
    *) echo "usage: $0 next|list" >&2; exit 1 ;;
esac
