#!/usr/bin/env bash
set -euo pipefail

cd -- "$(dirname -- "$0")/.."
mkdir -p backups
draft=$(mktemp backups/report-XXXXXXXX)
printf 'Текущий вывод сохраняется в %s\n' "$draft"

section() {
    local title=$1
    shift
    printf '\n## %s\n\n~~~text\n' "$title"
    "$@" || return $?
    printf '~~~\n'
}

{
    printf '# Отчёт о проверках Docker\n\n'
    printf 'Проверки выполнены последовательно командами из этого репозитория. Ниже приведён вывод команд.\n'
    section '4 и 6 баллов. Docker и Compose с SQLite' ./scripts/check-basics.sh || exit $?
    section '8 и 10 баллов. Redis, первый запуск' ./scripts/check.sh || exit $?
    section '8 и 10 баллов. Redis, второй запуск' ./scripts/check.sh || exit $?
} 2>&1 | tee "$draft"

mv -- "$draft" REPORT.md
printf '\nГотово. Результаты сохранены в REPORT.md\n'
