# Infrastrukturänderungen und Prüfungen

Stand: 15. Oktober 2026

Diese Notiz dokumentiert Arbeiten in der Ubuntu-VM im Projekt `/home/vboxuser/my-fisi-portfolio`. Sie enthält keine Zugangsdaten und keine Datenbankinhalte.

## PostgreSQL: Umstellung auf ein benanntes Volume

### Ausgangslage

Der Container `meine-datenbank` verwendete ein anonymes Docker-Volume für `/var/lib/postgresql/data`. In der Compose-Datei war dafür kein benanntes Volume deklariert.

### Änderung

- Datenbankcontainer gestoppt.
- Kalte Sicherung des PostgreSQL-Datenverzeichnisses erstellt: `/home/vboxuser/postgres-data-before-fix-2026-10-15.tar.gz`.
- Archivinhalt geprüft; die Datei war zum Prüfzeitpunkt 8,4 MB groß und hatte Modus `600`.
- Benanntes Docker-Volume `my-fisi-portfolio_postgres_data` erstellt.
- PostgreSQL-Daten aus dem bisherigen Volume in das neue Volume kopiert.
- Compose-Service `meine-datenbank` auf `postgres_data:/var/lib/postgresql/data` umgestellt.
- Compose-Konfiguration validiert und Datenbankcontainer gestartet.

### Prüfung

- `docker inspect` bestätigte `my-fisi-portfolio_postgres_data -> /var/lib/postgresql/data`.
- `pg_isready` meldete `accepting connections`.
- `psql` mit `\dt` meldete `Did not find any relations` für `fisi_db`. Zum Prüfzeitpunkt gab es in dieser Datenbank keine Tabellen.

Das alte anonyme Volume wurde nicht gelöscht. Die Sicherungsdatei und das alte Volume sollten erst entfernt werden, wenn Anwendung und Backups weiter geprüft sind.

## Portainer: Datenvolume korrigiert

### Ausgangslage

Das benannte Portainer-Volume war unter `/var/data` eingehängt. Portainer legt seine Daten unter `/data` ab. Dadurch wurden die aktiven Daten im Container unter `/data` in einem anonymen Volume gespeichert, während das benannte Volume leer blieb.

### Änderung und Prüfung

- Portainer vor der Änderung gestoppt.
- Vorhandene Daten gesichert unter `/home/vboxuser/portainer-data-before-fix-2026-10-14.tar.gz` und geprüft.
- Daten in das benannte Volume kopiert.
- Compose-Zuordnung auf `portainer_data:/data` korrigiert.
- Portainer gestartet; `docker inspect` bestätigte `my-fisi-portfolio_portainer_data -> /data`.
- Portainer war im Browser erreichbar; der lokale Docker-Endpunkt wurde als verbunden angezeigt.

## Automatische PostgreSQL-Sicherung

Im Benutzer-Crontab war dieser tägliche Auftrag eingetragen:

```cron
0 20 * * * /home/vboxuser/my-fisi-portfolio/backup.sh
```

Nach dem Start des Cron-Dienstes erschien um 20:00 Uhr ein neues Archiv unter `backups/`. Ein Archiv ließ sich auflisten und in die temporäre Datenbank `fisi_restore_test_20261010` einspielen; es traten dabei keine SQL-Fehler auf. Die Testdatenbank enthielt keine Tabellen. Das Skript sollte noch auf saubere Fehlerbehandlung geprüft werden, damit ein fehlgeschlagener Dump nicht als erfolgreiches Backup ausgegeben wird.

## Zugangsdaten und Veröffentlichung

Die Compose-Datei im Repository enthielt zuvor ein fest eingetragenes PostgreSQL-Passwort. Die aktuelle Compose-Datei liest es nun aus `POSTGRES_PASSWORD` in einer lokalen `.env`-Datei; `.env` wird von Git ausgeschlossen. Eine unvertrauliche Vorlage liegt in `.env.example`.

Da frühere Git-Commits weiterhin erreichbar sein können, muss das bisherige Passwort geändert werden, falls der veröffentlichte Wert tatsächlich in der laufenden Umgebung verwendet wurde. Ein Entfernen aus der aktuellen Datei löscht es nicht aus der Git-Historie.

Die `.tar.gz`-Sicherungen enthalten echte Portainer- bzw. PostgreSQL-Daten und gehören nicht in dieses Repository. Sie verbleiben lokal in der VM.

## Weiterführende Prüfung

Als Nächstes die Anwendung und ihre Datenbankverbindung prüfen. Danach das Backup-Skript auf Fehlerbehandlung kontrollieren und ein frisches Backup samt Wiederherstellungstest validieren.
