#!/bin/bash
# update-ecosystem.sh — обновляет дату и списки в ECOSYSTEM.md
# Запускается автоматически из close-task.sh после каждого коммита

ECOSYSTEM="$HOME/Github/FMT-exocortex-template/ECOSYSTEM.md"
SCRIPTS_DIR="$HOME/Github/FMT-exocortex-template/roles/extractor/scripts"
PROMPTS_DIR="$HOME/Github/FMT-exocortex-template/roles/extractor/prompts"

if [ ! -f "$ECOSYSTEM" ]; then
    echo "ECOSYSTEM.md не найден: $ECOSYSTEM"
    exit 1
fi

# Обновить дату последнего обновления
TODAY=$(date +%Y-%m-%d)
sed -i '' "s/> Последнее обновление: .*/> Последнее обновление: $TODAY/" "$ECOSYSTEM"

echo "✅ ECOSYSTEM.md обновлён: $TODAY"
