# Systopia CiviCRM Docker Stack

Docker-basierte Entwicklungs- und Testumgebung für CiviCRM mit klarer Trennung von
**Web**, **Datenbank**, **Tests**, **Mail**, **phpMyAdmin**, **CI (act)** und **Coverage**.

Optimiert für lokale Entwicklung von CiviCRM-Core und Systopia-Extensions.

---

## Zweck

- Lokale CiviCRM-Instanz mit reproduzierbarer Umgebung
- Separate Datenbanken für **Runtime** und **Tests**
- SMTP-Mail-Testing via **Mailpit**
- PHPUnit / CV-Tests mit Code-Coverage
- Zugriff auf interne und externe Datenbanken (SSH-Tunnel)
- Lokales Ausführen von GitHub Actions via **act**

---

## Enthaltene Services

| Service          | Zweck                       |
|------------------|-----------------------------|
| `civicrm`        | Apache + PHP + CiviCRM      |
| `civicrm-db`     | MariaDB (Runtime)           |
| `test-db`        | MariaDB (Tests)             |
| `testrunner`     | PHPUnit / cv test           |
| `test-db-init`   | Initialisiert Test-DB       |
| `civi-init`      | Einmalige Initialisierung   |
| `mailpit`        | SMTP + Web-UI               |
| `phpmyadmin`     | DB-Verwaltung (+SSH Tunnel) |
| `nginx-proxy`    | Reverse Proxy               |
| `acme-companion` | TLS (optional)              |
| `coverage`       | HTML Coverage Report        |
| `portainer`      | Docker UI                   |
| `act`            | imitiert Github Workflows   |

---

## Voraussetzungen

- Docker + Docker Compose
- Lokale Checkouts von:
    - `civicrm-core`
    - `civicrm-packages`
    - `systopiaExtensions`

Struktur (vereinfacht):
```
├─ systopiaDocker
├─ civicrm-core
├─ civicrm-packages
  ├─ DB
  ├─ HTML
  ├─ ...
├─ systopiaExtensions
  ├─ de.systopia.contract
  ├─ de.systopia.eventmessages
  ├─ ...
```

---

## Start

### Installation

```bash
docker compose up -d
```

Erster Start führt automatisch aus:

- initialisiert CiviCRM (ohne automatische Installation)
- installiert CiviCRM für Testrunner (mit automatischer Installation)
- Setzt CiviCRM Mail-Backend auf Mailpit
- Leert CiviCRM-Caches

---

### Zugriff / URLs
| Dienst                       | URL              |
|------------------------------|------------------|
| CiviCRM                      | http://civicrm   |
| phpMyAdmin                   | http://pma       | 
| PHPUnit Code Coverage Report | http://coverage  |
| Mailpit                      | http://mailpit   |
| Portainer                    | http://portainer |

Hosts für den nginx-proxy in  `/etc/hosts` anpassen:

```
#docker-hosts
127.0.0.1 civicrm
127.0.0.1 pma
127.0.0.1 coverage
127.0.0.1 mailpit
127.0.0.1 portainer
```
oder kurz:
```
#docker-hosts
127.0.0.1 civicrm pma coverage mailpit portainer
```

---

## Services 

### Reverse Proxy / TLS

nginx-proxy routet per VIRTUAL_HOST

acme-companion generiert bei Bedarf automatisch TLS-Zertifikate

### Mailpit

Dient dazu, E-Mails von CiviCRM auf einen lokalen Entwicklungs-SMTP umzuleiten.

- SMTP: mailpit:1025
- Keine Authentifizierung
- Konfiguration erfolgt per cv (beim Initiatlisieren des Setups)

Script:
`init/civi-mail.sh`

---

## Tests

Tests laufen im testrunner-Container gegen test-db. (Transactions, Rollbacks, ...)

Im Container: 

```
cd /var/www/html/ext/[EXTENSION] 
composer phpunit:html
```

Das Output landet im gemounteten Verzeichnis für den Coverage-Container:
`../coverage/`

Abrufbar über coverage-Service. http://coverage

### Test-Datenbank

Automatisches Setup durch:

`init/test-db.sh`

Features:
- Wartet auf DB
- Erstellt DB sauber neu
- Führt `cv core:install` aus
- Skip, wenn bereits installiert

---

## phpMyAdmin + SSH-Tunnel

Zusätzlicher externer DB-Zugriff (für Kunden-Datenbanken) über SSH-Tunnel: `./ssh-tunnel.sh`

- Lokal: localhost:3307
- phpMyAdmin zeigt Server: SSH Tunnel (extern)

Config: `phpmyadmin/config.user.inc.php`

### Nutzung

- Tunnel starten
- Serverdaten eingeben (SSH-Key wird mitgeliefert)
- in phpMyAdmin den Server `SSH Tunnel (extern)` wählen
- Login-Daten für DB aus Wallet kopieren
- Einloggen

Aktuell wird nur ein Tunnel unterstützt.

---

## Logs

CiviCRM-Logs werden live getailed.

- Script: logtail.sh
- Pfad: /private/log/*.log
- Ausgabe auf Container-STDOUT

---

## act (GitHub Actions lokal)

im Container:
```
cd [EXTENSION]
act-pull phpunit 8.1 lowest
```

als Shortcut für:
```
act pull_request -j phpstan \
--matrix php-versions:8.1 \
--matrix prefer:prefer-lowest \
--rm
```

act-pull kann:
- phpunit, phpstan
- 8.1, 8.4
- lowest, stable

(hat autocomplete)

---

## Konfiguration

- .env

  Zentrale Steuerung für DBs, Ports, Credentials

- docker-compose.yml

  Alle Services, Volumes, Netzwerke

- Dockerfile.testrunner
  
  PHP-Erweiterungen, cv, civix, pcov, Composer

- .actrc
  
  Definiert das image für die workflows 

---

## Netzwerke

| Netzwerk   | Zweck                 |
| ---------- | --------------------- |
| `backend`  | interne Kommunikation |
| `frontend` | Proxy / HTTP Zugriff  |

---

## Hinweise

- Volumes sind persistent
- Kein Produktions-Setup

---

### Ausführung von "civicrm-extension-template"

Anleitung hier folgen: https://github.com/systopia/civicrm-extension-template

#### PHPUnit

Damit PHPUnit die Test-Datenbank `test-db` findet, muss die [bootstrap.local.php](https://github.com/ArthegaAsdweri/civicrm-dev-docker/blob/master/extension-conf/bootstrap.local.php) wie folgt eingebunden werden.

```
├─ tests
  ├─ phpunit
     ├─ bootstrap.local.php
     ├─ bootstrap.php
```

#### PHPStan

Die [phpstan.neon](https://github.com/ArthegaAsdweri/civicrm-dev-docker/blob/master/extension-conf/phpstan.neon) muss im Extension-Root liegen.

In 90% der Fälle reicht:

```
includes:
  - phpstan.neon.dist
parameters:
  scanDirectories:
    - ../../core
```

In manchen Extensions sind aber komplexere "Needs" vorhanden. Die Beispiel-Datei bildet solche Needs ab.