#!/bin/bash

# Konfiguration
BACKUP_DIR="/home/vboxuser/my-fisi-portfolio/backups"
DATE=$(date '+%Y-%m-%d_%H-%M-%S')
FILENAME="postgres_backup_$DATE.sql"

echo "=== Datensicherung gestartet: $DATE ==="

# Erstellt ein Backup der PostgreSQL-Datenbank direkt im laufenden Docker-Container
docker exec meine-datenbank pg_dump -U fisi_user -d fisi_db > "$BACKUP_DIR/$FILENAME"

# Komprimiert die .sql Datei in ein geschütztes .tar.gz Archiv, um Speicherplatz zu sparen
tar -czf "$BACKUP_DIR/$FILENAME.tar.gz" -C "$BACKUP_DIR" "$FILENAME"

# Löscht die temporäre unkomprimierte .sql Datei
rm "$BACKUP_DIR/$FILENAME"

echo "=== Backup erfolgreich erstellt und archiviert! ==="
ls -l "$BACKUP_DIR"
