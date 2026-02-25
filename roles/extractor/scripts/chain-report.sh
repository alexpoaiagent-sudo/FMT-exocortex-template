#!/bin/bash
# chain-report.sh — финальный отчёт по всей цепочке после сессии стратегирования
# Показывает что прошло по цепочке от творческого конвейера до PACK
# Сохраняет отчёт в DS-strategy/inbox/extraction-reports/

SESSION_FILE="${1:-}"
DS_STRATEGY="$HOME/Github/DS-strategy"
CAPTURES="$DS_STRATEGY/inbox/captures.md"
PROCESSED="$DS_STRATEGY/inbox/processed-sessions"
REPORTS="$DS_STRATEGY/inbox/extraction-reports"
REPORT_FILE="$REPORTS/$(date +%Y-%m-%d)-chain-report.md"

mkdir -p "$REPORTS"

# Инициализируем файл отчёта
echo "" > "$REPORT_FILE"

# Пишет и в терминал и в файл
out() { echo "$1" | tee -a "$REPORT_FILE"; }

out ""
out "════════════════════════════════════════════════════════════"
out "📋 ОТЧЁТ ЦЕПОЧКИ СТРАТЕГИРОВАНИЯ $(date '+%d.%m.%Y %H:%M')"
out "════════════════════════════════════════════════════════════"
out ""

# 1. Файл сессии
out "① ТВОРЧЕСКИЙ КОНВЕЙЕР"
if [ -n "$SESSION_FILE" ] && [ -f "$SESSION_FILE" ]; then
    fname=$(basename "$SESSION_FILE")
    fsize=$(wc -c < "$SESSION_FILE")
    out "   ✅ Файл сессии создан: $fname"
    out "   📄 Размер: $fsize байт"
else
    last=$(ls -t "$PROCESSED"/*.md 2>/dev/null | head -1)
    if [ -n "$last" ]; then
        fname=$(basename "$last")
        out "   ✅ Последняя сессия: $fname"
    else
        out "   ⚠️  Файл сессии не найден"
    fi
fi
out ""

# 2. Pending → Processed
out "② ЭКСТРАКТОР (session-import)"
processed_count=$(ls "$PROCESSED"/*.md 2>/dev/null | wc -l | tr -d ' ')
pending_count=$(ls "$DS_STRATEGY/inbox/pending-sessions"/*.md 2>/dev/null | wc -l | tr -d ' ')
if [ "$processed_count" -gt 0 ]; then
    out "   ✅ Обработано сессий: $processed_count"
    ls -t "$PROCESSED"/*.md 2>/dev/null | head -3 | while read f; do
        out "   → $(basename "$f")"
    done
else
    out "   ⚠️  Нет обработанных сессий"
fi
if [ "$pending_count" -gt 0 ]; then
    out "   ⏳ В очереди: $pending_count (session-watcher обработает через ~5 мин)"
fi
out ""

# 3. Captures в inbox
out "③ DS-STRATEGY INBOX (captures.md)"
if [ -f "$CAPTURES" ]; then
    capture_count=$(grep -c "^### " "$CAPTURES" 2>/dev/null || echo 0)
    out "   ✅ Captures в inbox: $capture_count"
    grep "^### " "$CAPTURES" 2>/dev/null | sed 's/^### /   → /' | head -10 | while read line; do
        out "$line"
    done
else
    out "   ⚠️  captures.md не найден"
fi
out ""

# 4. Последний отчёт inbox-check
out "④ ЭКСТРАКТОР (inbox-check → PACK)"
last_report=$(ls -t "$REPORTS"/*inbox-check*.md 2>/dev/null | head -1)
if [ -n "$last_report" ]; then
    rname=$(basename "$last_report")
    accept=$(grep -c "accept" "$last_report" 2>/dev/null || echo 0)
    reject=$(grep -c "reject" "$last_report" 2>/dev/null || echo 0)
    out "   ✅ Последний отчёт: $rname"
    out "   ✅ Принято: $accept | Отклонено: $reject"
    grep "CO\." "$last_report" 2>/dev/null | head -5 | while read line; do
        out "   → $line"
    done
else
    out "   ⏳ inbox-check ещё не запускался"
    out "   Запустить вручную:"
    out "   bash ~/Github/FMT-exocortex-template/roles/extractor/scripts/claude-run.sh inbox-check"
fi
out ""

out "════════════════════════════════════════════════════════════"
out "✅ ЦЕПОЧКА СТРАТЕГИРОВАНИЯ ЗАВЕРШЕНА"
out ""
out "Если что-то не прошло автоматически — ручные команды:"
out "  Обработать очередь:  bash ~/Github/FMT-exocortex-template/roles/extractor/scripts/claude-run.sh session-watcher"
out "  Проверить inbox:     bash ~/Github/FMT-exocortex-template/roles/extractor/scripts/claude-run.sh inbox-check"
out "  Посмотреть captures: cat ~/Github/DS-strategy/inbox/captures.md"
out "  Посмотреть лог:      cat ~/logs/extractor/$(date +%Y-%m-%d).log"
out "════════════════════════════════════════════════════════════"
out ""
out "📁 Отчёт сохранён: $REPORT_FILE"
