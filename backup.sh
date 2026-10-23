#!/usr/bin/env bash
set -Eeuo pipefail

# Neue Dateien und Backups bleiben standardmäßig nur für den Benutzer lesbar.
umask 077

# Backups neben dem Skript ablegen, unabhängig vom aktuellen Terminal-Ordner.
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="${SCRIPT_DIR}/backups"
CONTAINER_NAME="meine-datenbank"
DB_USER="fisi_user"
DB_NAME="fisi_db"
DATE="$(date '+%Y-%m-%d_%H-%M-%S')"

mkdir -p -- "$BACKUP_DIR"
chmod 700 -- "$BACKUP_DIR"

# Erst in eine temporäre Datei schreiben. Bei einem Fehler wird sie entfernt.
TEMP_FILE="$(mktemp "${BACKUP_DIR}/.postgres_backup_${DATE}.XXXXXX")"
RANDOM_SUFFIX="${TEMP_FILE##*.}"
BACKUP_FILE="${BACKUP_DIR}/postgres_backup_${DATE}_${RANDOM_SUFFIX}.sql.gz"
trap 'rm -f -- "$TEMP_FILE"' EXIT

printf 'Datensicherung gestartet: %s\n' "$DATE"

# pipefail sorgt dafür, dass auch Fehler von pg_dump oder gzip erkannt werden.
docker exec "$CONTAINER_NAME" pg_dump -U "$DB_USER" -d "$DB_NAME" | gzip -c > "$TEMP_FILE"

# Nur eine lesbare und intakte gzip-Datei wird als fertiges Backup abgelegt.
gzip -t -- "$TEMP_FILE"
if ! mv -n -- "$TEMP_FILE" "$BACKUP_FILE"; then
  printf 'Fehler: Backup konnte nicht abgelegt werden.\n' >&2
  exit 1
fi
if [[ -e "$TEMP_FILE" ]]; then
  printf 'Fehler: Zieldatei existiert bereits; Backup wurde nicht überschrieben.\n' >&2
  exit 1
fi

printf 'Backup erfolgreich erstellt: %s\n' "$BACKUP_FILE"
ls -lh -- "$BACKUP_FILE"
