#!/bin/bash
# cache-cap — держит файловый кэш vpnvm не больше CAP_MB.
# Сверху ядро просят вытеснить самые давно не нужные страницы (memory.reclaim),
# освобождённое виртуалка отдаёт pcomp сама (balloon с freePageReporting).
# Иначе гость копит кэш на весь объём, а pcomp уносит его к себе в своп.
# Своего свопа у vpnvm нет, поэтому вытесняется только кэш, программы не трогаются.
# Signed: pluttan
# НЕ ВКЛЮЧАТЬ, пока память vpnvm лежит в свопе pcomp: 03.10.2026 первый проход
# (вытеснить 8 ГБ разом) полз ~5 МБ/с, процесс нельзя было убить, виртуалка лагала ~20 мин.
# Сначала вернуть память из свопа pcomp, потом включать (make install).

CAP_MB=${CAP_MB:-1024}
INTERVAL=${INTERVAL:-30}

while :; do
    # Кэш, который можно выкинуть: Cached + Buffers без tmpfs (Shmem) — тот живёт в памяти, пока файл есть.
    cache=$(awk '/^Cached:/{c=$2} /^Buffers:/{b=$2} /^Shmem:/{s=$2} END{print int((c+b-s)/1024)}' /proc/meminfo)
    if (( cache > CAP_MB )); then
        over=$(( cache - CAP_MB ))
        # Порциями по 256 МБ: одна большая просьба держит процесс в ядре минутами,
        # и службу не остановить, пока она не закончится.
        # EAGAIN — ядро не набрало столько холодных страниц; это нормально, следующий проход доберёт.
        left=$over
        while (( left > 0 )); do
            chunk=$(( left > 256 ? 256 : left ))
            echo "${chunk}M" > /sys/fs/cgroup/memory.reclaim 2>/dev/null || break
            left=$(( left - chunk ))
        done
        (( over >= 256 )) && echo "кэш ${cache} МБ > ${CAP_MB} — вытеснено до $(awk '/^Cached:/{c=$2} /^Buffers:/{b=$2} /^Shmem:/{s=$2} END{print int((c+b-s)/1024)}' /proc/meminfo) МБ"
    fi
    sleep "$INTERVAL"
done
