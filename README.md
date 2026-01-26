# Systopia CiviCRM Docker Stack

Docker-basierte Entwicklungs- und Testumgebung für **CiviCRM** mit klarer Trennung von  
**Web**, **Datenbank**, **Tests**, **Mail**, **phpMyAdmin** und **Coverage**.

Optimiert für lokale Entwicklung von CiviCRM-Core und Systopia-Extensions.

---

## Zweck

- Lokale CiviCRM-Instanz mit reproduzierbarer Umgebung
- Separate Datenbanken für **Runtime** und **Tests**
- SMTP-Mail-Testing via **Mailpit**
- PHPUnit / CV-Tests mit Code-Coverage
- Zugriff auf interne und externe Datenbanken (SSH-Tunnel)

---

## Enthaltene Services

| Service | Zweck |
|------|------|
| `civicrm` | Apache + PHP + CiviCRM |
| `civicrm-db` | MariaDB (Runtime) |
| `test-db` | MariaDB (Tests) |
| `testrunner` | PHPUnit / cv test |
| `mailpit` | SMTP + Web-UI |
| `phpmyadmin` | DB-Verwaltung |
| `nginx-proxy` | Reverse Proxy |
| `acme-companion` | TLS (optional) |
| `coverage` | HTML Coverage Report |
| `civi-init` | Einmalige Initialisierung |

---

## Voraussetzungen

- Docker + Docker Compose
- Lokale Checkouts von:
    - `civicrm-core`
    - `civicrm-packages`
    - `systopiaExtensions`

Struktur (vereinfacht):
`
├─ systopiaDocker
├─ civicrm-core
├─ civicrm-packages
├─ systopiaExtensions
`

---

## Start

### Installation

```bash
docker compose up -d
```

Erster Start führt automatisch aus:

- init/civi-mail.sh
- Setzt CiviCRM Mail-Backend auf Mailpit
- Leert CiviCRM-Caches

---

### Wichtige URLs
| Dienst                       | URL             |
|------------------------------|-----------------|
| CiviCRM                      | http://civicrm  |
| phpMyAdmin                   | http://pma      | 
| PHPUnit Code Coverage Report | http://coverage |
| Mailpit                      | http://mailpit  |

Hosts für den nginx-proxy in  `/etc/hosts` anpassen:

```
#docker-hosts
127.0.0.1 civicrm
127.0.0.1 pma
127.0.0.1 coverage
127.0.0.1 mailpit
```

---

## Services 

### Mailpit

Dient dazu, E-Mails von CiviCRM auf einen lokalen Entwicklungs-SMTP umzuleiten.

- SMTP: mailpit:1025
- Keine Authentifizierung
- Konfiguration erfolgt per cv (beim Initiatlisieren des Setups)

Script:
`init/civi-mail.sh`

---

## Tests

Tests laufen im testrunner-Container gegen test-db. (Tranasctions, Rollbacks, ...)

Im Container z.B. wechseln auf 

```/var/www/html/ext/[EXTENSION]``` 

und anschließend aufrufen:

`composer phpunit:html`

Das Output landet im gemounteten Verzeichnis für den Coverage-Container:
`../coverage/`


Abrufbar über coverage-Service.

---

## phpMyAdmin + SSH-Tunnel

Zusätzlicher externer DB-Zugriff über SSH-Tunnel:

./ssh-tunnel.sh

- Lokal: localhost:3307
- phpMyAdmin zeigt Server: SSH Tunnel (extern)

Config:
phpmyadmin/config.user.inc.php

---

## Logs

CiviCRM-Logs werden live getailed.

- Script: logtail.sh
- Pfad: /private/log/*.log
- Ausgabe auf Container-STDOUT

---

## Konfiguration

- .env
  Zentrale Steuerung für DBs, Ports, Credentials

- docker-compose.yml
  Alle Services, Volumes, Netzwerke

- Dockerfile.testrunner
  PHP-Erweiterungen, cv, civix, pcov, Composer

---

## Hinweise

- Volumes sind persistent
- civi-init läuft nur einmal
- Kein Produktions-Setup
- Reverse-Proxy / TLS optional

---