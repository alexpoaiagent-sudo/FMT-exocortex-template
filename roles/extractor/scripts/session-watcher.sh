#!/bin/bash
# Session Watcher — следит за pending-sessions/, запускает session-import
# Запускается launchd каждые 5 минут из чистой среды (без CLAUDECODE)

PENDING_DIR="/Users/alexander/Github/DS-strategy/inbox/pending-sessions"
PROCESSED_DIR="/Users/alexander/Github/DS-strategy/inbox/processed-sessions"
EXTRACTOR="/Users/alexander/Github/FMT-exocortex-template/roles/extractor/scripts/extractor.sh"
LOG_DIR="/Users/alexander/logs/extractor"
LOG_FILE="$LOG_DIR/$(date +%Y-%m-%d).log"

mkdir -p "$LOG_DIR" "$PROCESSED_DIR"

# Снимаем блокировку вложенных сессий Claude Code
unset CLAUDECODE

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [session-watcher] $1" >> "$LOG_FILE"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [session-watcher] $1"
}

# Проверяем есть ли файлы в очереди
pending=$(ls "$PENDING_DIR"/*.md 2>/dev/null)
if [ -z "$pending" ]; then
    exit 0
fi

log "Найдены файлы в очереди: $(echo "$pending" | wc -l | tr -d ' ')"

for session_file in "$PENDING_DIR"/*.md; do
    [ -f "$session_file" ] || continue
    fname=$(basename "$session_file")
    log "Обрабатываю: $fname"

    # Передаём путь к файлу через env переменную
    export SESSION_IMPORT_FILE="$session_file"
    bash "$EXTRACTOR" session-import >> "$LOG_FILE" 2>&1
    status=$?

    if [ $status -eq 0 ]; then
        mv "$session_file" "$PROCESSED_DIR/$fname"
        log "✅ Готово: $fname → processed-sessions/"
    else
        log "❌ Ошибка обработки: $fname (код $status)"
    fi
done
