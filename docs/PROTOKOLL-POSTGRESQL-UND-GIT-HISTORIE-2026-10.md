# Betriebsprotokoll: PostgreSQL-Volume, Sicherung und Git-Historie

**Projekt:** FiSi IT Homelab  
**Zeitraum:** Oktober 2026

Dieses Protokoll hält die durchgeführten Änderungen fest. Es enthält absichtlich keine Passwörter, geheimen Werte, `.env`-Dateien oder Datenbanksicherungen.

## PostgreSQL-Datenvolume

- Das PostgreSQL-Datenverzeichnis lag zunächst auf einem anonymen Docker-Volume.
- Der Datenbankcontainer wurde gestoppt und das Volume vor der Umstellung als TAR.GZ-Datei gesichert. Das Archiv wurde geprüft und mit Zugriffsrechten `600` geschützt.
- Das vorhandene Datenverzeichnis wurde in das benannte Volume `my-fisi-portfolio_postgres_data` kopiert.
- `docker-compose.yml` bindet dieses Volume als `postgres_data` am Containerpfad `/var/lib/postgresql/data` ein.
- Die Mount-Zuordnung wurde mit `docker inspect` kontrolliert. Der alte anonyme Volume-Eintrag wurde dabei nicht gelöscht.
- Der PostgreSQL-Container startete anschließend. `pg_isready` meldete, dass Verbindungen angenommen werden.

## Sicherung, Wiederherstellung und Passwortwechsel

- Vor dem Passwortwechsel wurde ein logischer PostgreSQL-Dump mit `pg_dump` komprimiert. Der gzip-Test war erfolgreich. Die lokale Sicherung liegt unter `backups/`; dieser Ordner ist von Git ausgeschlossen und die Sicherung wurde nicht hochgeladen.
- Das verbesserte `backup.sh` wurde ausgeführt und erzeugte am 23.10.2026 eine 370 Byte große gzip-Sicherung. Die Dateirechte waren `600`; der integrierte gzip-Test lief erfolgreich.
- Diese Sicherung wurde in einer temporären PostgreSQL-15-Testinstanz wiederhergestellt. Der Testcontainer hatte kein Netzwerk und keinen veröffentlichten Port; die laufende Datenbank wurde nicht verändert.
- `psql` spielte den SQL-Dump ohne gemeldeten Fehler ein. Die anschließende Abfrage fand 0 Anwendungstabellen, passend zum zuvor geprüften leeren Datenbankstand.
- Der Testcontainer und sein temporärer Speicher wurden danach entfernt. Damit ist der Restore des damaligen leeren Datenbankstands geprüft; eine Wiederherstellung späterer Anwendungsdaten ist noch nicht getestet.
- Zum Prüfzeitpunkt meldete `psql \dt`, dass keine Tabellen vorhanden waren.
- Das Passwort des Datenbankbenutzers `fisi_user` wurde interaktiv in PostgreSQL geändert. Der Wert wurde weder in dieses Repository geschrieben noch hier dokumentiert.
- `.env` enthält lokal den neuen Wert, hat Zugriffsrechte `600` und wird von Git ignoriert. Die Compose-Konfiguration liest `POSTGRES_PASSWORD` aus dieser lokalen Datei.
- Die Compose-Konfiguration wurde geprüft; der Container wurde neu erstellt. `pg_isready` und eine TCP-Anmeldung mit `psql` waren erfolgreich.

## Bereinigung der veröffentlichten Git-Historie

- Das frühere Passwort stand in älteren Commits in einer Compose-Datei. Der Passwortwechsel machte diesen alten Wert ungültig, entfernte ihn aber nicht aus Git.
- Die Bereinigung wurde in einer separaten, sauberen Kopie des GitHub-Repositories mit `git-filter-repo` durchgeführt. Ein lokaler Ersetzungseintrag ersetzte den alten Wert in den Commits durch einen neutralen Marker.
- Es wurden 21 Commits neu geschrieben. Die Bereinigungskopie enthielt nur den Branch `main` und keine Tags.
- Die Historie wurde geprüft: Der alte Wert wurde in der bereinigten Historie nicht mehr gefunden. Der Marker ist in den Änderungen der betroffenen Compose-Datei sichtbar; spätere Commits verwenden die Umgebungsvariable.
- Der bereinigte Branch `main` wurde mit einem Force-Push nach GitHub übertragen. Der lokale Stand und GitHub-`main` stimmten anschließend überein.
- Die beiden lokalen Ersetzungsdateien wurden nach der Prüfung gelöscht.

## Hinweise für die weitere Arbeit

- Die ursprüngliche Arbeitskopie `~/my-fisi-portfolio` behält ihre alte lokale Git-Historie und lokale Änderungen. Von dort darf die alte Historie nicht nach GitHub gepusht werden.
- Alte Klone sollten verworfen und frisch vom bereinigten GitHub-Repository geklont werden. Vor dem Ersetzen einer Arbeitskopie müssen benötigte lokale Änderungen und Dateien wie `.env` separat gesichert werden.
- Datenbank-Backups und `.env` bleiben lokal und gehören nicht in Git.
- GitHub oder Forks können noch zwischengespeicherte Verweise auf frühere Commits haben. Das alte Passwort ist geändert; bei weiterhin sichtbaren alten Ansichten kann GitHub Support um Cache-Bereinigung gebeten werden.

## 28.10.2026 – PostgreSQL-Port nicht mehr auf dem Host veröffentlichen

In `docker-compose.yml` wurde die Portfreigabe `5432:5432` beim Dienst
`meine-datenbank` entfernt. PostgreSQL ist damit nicht mehr direkt über einen
Port des Ubuntu-Hosts erreichbar. Container im Docker-Netzwerk und lokale
Prüfungen mit `docker exec` können weiterhin auf die Datenbank zugreifen.

Das vorhandene Daten-Volume wird ausdrücklich als externes Docker-Volume
verwendet:

- Volume: `my-fisi-portfolio_postgres_data`
- Einhängepunkt: `/var/lib/postgresql/data`

Prüfergebnis am 28.10.2026:

- `docker compose ... config -q`: erfolgreich, keine Konfigurationsfehler.
- `pg_isready`: `/var/run/postgresql:5432 - accepting connections`
- `docker inspect`: bestätigt das erwartete Daten-Volume am PostgreSQL-Einhängepunkt.
- `docker ps`: zeigt nur `5432/tcp`; es gibt keine Host-Port-Zuordnung wie
  `0.0.0.0:5432->5432`.
