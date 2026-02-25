#!/bin/bash
# chain-report.sh — финальный отчёт по всей цепочке после сессии стратегирования
# Показывает что прошло по цепочке от творческого конвейера до PACK

SESSION_FILE="${1:-}"
LOG_DIR="$HOME/logs/extractor"
DS_STRATEGY="$HOME/Github/DS-strategy"
CAPTURES="$DS_STRATEGY/inbox/captures.md"
PROCESSED="$DS_STRATEGY/inbox/processed-sessions"
REPORTS="$DS_STRATEGY/inbox/extraction-reports"

echo ""
echo "════════════════════════════════════════════════════════════"
echo "📋 ОТЧЁТ ЦЕПОЧКИ СТРАТЕГИРОВАНИЯ"
echo "════════════════════════════════════════════════════════════"
echo ""

# 1. Файл сессии
echo "① ТВОРЧЕСКИЙ КОНВЕЙЕР"
if [ -n "$SESSION_FILE" ] && [ -f "$SESSION_FILE" ]; then
    fname=$(basename "$SESSION_FILE")
    fsize=$(wc -c < "$SESSION_FILE")
    echo "   ✅ Файл сессии создан: $fname"
    echo "   📄 Размер: $fsize байт"
else
    # Найти последний обработанный файл
    last=$(ls -t "$PROCESSED"/*.md 2>/dev/null | head -1)
    if [ -n "$last" ]; then
        fname=$(basename "$last")
        echo "   ✅ Последняя сессия: $fname"
    else
        echo "   ⚠️  Файл сессии не найден"
    fi
fi
echo ""

# 2. Pending → Processed
echo "② ЭКСТРАКТОР (session-import)"
processed_count=$(ls "$PROCESSED"/*.md 2>/dev/null | wc -l | tr -d ' ')
pending_count=$(ls "$DS_STRATEGY/inbox/pending-sessions"/*.md 2>/dev/null | wc -l | tr -d ' ')
if [ "$processed_count" -gt 0 ]; then
    echo "   ✅ Обработано сессий: $processed_count"
    ls -t "$PROCESSED"/*.md 2>/dev/null | head -3 | while read f; do
        echo "   → $(basename "$f")"
    done
else
    echo "   ⚠️  Нет обработанных сессий"
fi
if [ "$pending_count" -gt 0 ]; then
    echo "   ⏳ В очереди: $pending_count (session-watcher обработает через ~5 мин)"
fi
echo ""

# 3. Captures в inbox
echo "③ DS-STRATEGY INBOX (captures.md)"
if [ -f "$CAPTURES" ]; then
    capture_count=$(grep -c "^### " "$CAPTURES" 2>/dev/null || echo 0)
    echo "   ✅ Captures в inbox: $capture_count"
    grep "^### " "$CAPTURES" 2>/dev/null | sed 's/^### /   → /' | head -10
else
    echo "   ⚠️  captures.md не найден"
fi
echo ""

# 4. Последний отчёт inbox-check
echo "④ ЭКСТРАКТОР (inbox-check → PACK)"
last_report=$(ls -t "$REPORTS"/*.md 2>/dev/null | head -1)
if [ -n "$last_report" ]; then
    rname=$(basename "$last_report")
    accept=$(grep -c "accept" "$last_report" 2>/dev/null || echo 0)
    reject=$(grep -c "reject" "$last_report" 2>/dev/null || echo 0)
    echo "   ✅ Последний отчёт: $rname"
    echo "   ✅ Принято: $accept | Отклонено: $reject"
    grep "CO\." "$last_report" 2>/dev/null | head -5 | sed 's/^/   → /'
else
    echo "   ⏳ inbox-check ещё не запускался"
    echo "   Запустить вручную:"
    echo "   bash ~/Github/FMT-exocortex-template/roles/extractor/scripts/claude-run.sh inbox-check"
fi
echo ""

echo "════════════════════════════════════════════════════════════"
echo "✅ ЦЕПОЧКА СТРАТЕГИРОВАНИЯ ЗАВЕРШЕНА"
echo ""
echo "Если что-то не прошло автоматически — ручные команды:"
echo "  Обработать очередь:  bash ~/Github/FMT-exocortex-template/roles/extractor/scripts/claude-run.sh session-watcher"
echo "  Проверить inbox:     bash ~/Github/FMT-exocortex-template/roles/extractor/scripts/claude-run.sh inbox-check"
echo "  Посмотреть captures: cat ~/Github/DS-strategy/inbox/captures.md"
echo "  Посмотреть лог:      cat ~/logs/extractor/$(date +%Y-%m-%d).log"
echo "════════════════════════════════════════════════════════════"
echo ""
