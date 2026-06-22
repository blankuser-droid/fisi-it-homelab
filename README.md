# Mein erstes IT-Infrastruktur Projekt (FiSi Lab)

In diesem Projekt habe ich eine eigene Testumgebung (Homelab) für die Fachrichtung Systemintegration aufgebaut.

## Technische Details:
- **Hypervisor:** Oracle VirtualBox
- **Betriebssystem:** Ubuntu Linux (Server/Desktop)
- **Fernverwaltung:** SSH (Port 22)
- **Containerisierung:** Docker & Docker Compose (Multi-Container Setup)
- **Webserver:** Nginx im Docker-Container (Port-Forwarding 8080:80)
- **Datenbank:** PostgreSQL 15 (Alpine-basiert, Port 5432)
- **Netzwerk:** Isoliertes Docker-Netzwerk (Bridge-Modus) für sichere Container-Kommunikation
- **Automatisierung:** Bash-Skript für regelmäßige Datensicherung (PostgreSQL pg_dump & tar-Komprimierung)

## Was ich gelernt habe:
- Linux-Administration über das Terminal (CLI)
- Netzwerkbrücke (Bridged Adapter) Konfiguration und Troubleshooting
- Docker-Architektur, Container-Isolierung und Docker Networking
- Sichere Verwaltung von Umgebungsvariablen (Environment Variables) in Datenbanken
- Shell-Scripting (Bash) zur Automatisierung von Systemprozessen (Backup/Datensicherung)
- Systematisches Troubleshooting bei Netzwerk-, Berechtigungs- und Syntaxfehlern

## Screenshot des laufenden Webservers
![Welcome to Nginx](screenshot.png)

*Hinweis: Der Webserver läuft im lokalen Testnetzwerk unter der IP-Adresse http://192.168.2.128:8080*
