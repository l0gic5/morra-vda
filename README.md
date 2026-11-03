<a id="english"></a>

[🇬🇧 English](#english) · [🇮🇹 Italiano](#italiano)

# 🤟 Morra Valdostana – Tournament App

> Mobile app (iOS and Android) to organise, play and follow **Morra Valdostana** tournaments: stage calendar, sign-ups with check-in, live standings, an offline match score counter and season rankings.

**Status:** early development (the offline score counter and the rules package exist; backend not started yet)
**Stack:** Flutter · Serverpod (Dart) · PostgreSQL · Docker

The full design document (rules, features, data model, roadmap, open questions) is in [`docs/PROJECT.md`](docs/PROJECT.md).

## Repository layout

```
morra_vda/
 ├─ apps/
 │   ├─ mobile/            # Flutter app (Android / iOS)
 │   └─ server/            # Serverpod backend (planned)
 ├─ packages/
 │   ├─ morra_rules/       # rules engine, pure Dart (scoring, later pairing and ranking)
 │   └─ morra_client/      # Serverpod-generated client (planned)
 └─ docs/
     └─ PROJECT.md         # design document
```

Each folder is an independent Dart/Flutter package. `morra_rules` has no Flutter dependency, so the app and the server can both import it.

## Architecture in short

| Component     | Choice                                                                                    |
| ------------- | ----------------------------------------------------------------------------------------- |
| Mobile app    | **Flutter / Dart**                                                                        |
| Backend       | **Serverpod** (Dart): endpoints, ORM, migrations, auth module, scheduled jobs, streaming  |
| Database      | **PostgreSQL**                                                                            |
| Hosting       | Self-hosted on SSD Nodes with **Docker Compose**, exposed through **Cloudflare Tunnel**   |
| Rules engine  | `packages/morra_rules`, **one implementation shared by app and server**                   |
| Offline       | Scores recorded as **events** with client-generated unique IDs, stored locally and synced |
| Admin console | Planned as Flutter Web using the same generated client (a Nuxt front end stays possible)  |
| Push          | Logic on the server, delivery through FCM (Android) and APNs (iOS)                        |

Key ideas:

- **Offline first.** Games are played in mountain bars with poor coverage. The app counts points locally and syncs later.
- **Scores as events.** Each tap records an event (point, hand lowered, undo). The score is derived from the event log, so undo, history and replay come for free.
- **The server is the authority.** The client applies the rules locally for live counting; the server inserts events idempotently, replays them with the same `morra_rules` code and publishes the official result.

## Getting started

Requirements: Flutter SDK (which includes Dart) and an Android device or emulator.

```bash
# rules engine
cd packages/morra_rules
dart pub get
dart test

# mobile app
cd apps/mobile
flutter pub get
flutter run
```

The backend is not in the repository yet. When it is, its setup (Docker Compose with Postgres) will be documented in `apps/server/README.md`.

## Roadmap (short)

1. **MVP**: backend, registration and roles, stage calendar, booking and QR check-in, offline score counter, stage ranking.
2. **Live tournament**: automatic pairings, live mode, season ranking with admin validation, notifications.
3. **Community**: photos, statistics, hall of fame, exports, public pages, Italian / French.

Details are in [`docs/PROJECT.md`](docs/PROJECT.md).

## Data and privacy of this repository

This repository contains **no real personal data**. Players, teams, tournaments, results, photos and payments used in tests, fixtures, screenshots and examples are **entirely fictitious**.

- Real player data (profiles, photos, fees) will only ever live in the production database on the self-hosted server, never in the repository or its history.
- Secrets (passwords, API keys, tokens, `.env` files) are not committed. Configuration templates use placeholders (for example `.env.example`).
- Seed and test data must be made up. Do not paste real names, emails, phone numbers or photos of real people.

## License

See [`LICENSE`](LICENSE).

---

<a id="italiano"></a>

[🇬🇧 English](#english) · [🇮🇹 Italiano](#italiano)

# 🤟 Morra Valdostana – App per i tornei

> App mobile (iOS e Android) per organizzare, giocare e seguire i tornei di **Morra Valdostana**: calendario delle tappe, iscrizioni con check-in, classifica live, conta-partite offline e classifica di stagione.

**Stato:** sviluppo iniziale (esistono il conta-partite offline e il package delle regole; il backend non è ancora iniziato)
**Stack:** Flutter · Serverpod (Dart) · PostgreSQL · Docker

Il documento di progetto completo (regole, funzionalità, modello dati, roadmap, punti da definire) è in [`docs/PROJECT.md`](docs/PROJECT.md).

## Struttura del repository

```
morra_vda/
 ├─ apps/
 │   ├─ mobile/            # app Flutter (Android / iOS)
 │   └─ server/            # backend Serverpod (previsto)
 ├─ packages/
 │   ├─ morra_rules/       # motore regole, Dart puro (conteggio, poi abbinamenti e classifiche)
 │   └─ morra_client/      # client generato da Serverpod (previsto)
 └─ docs/
     └─ PROJECT.md         # documento di progetto
```

Ogni cartella è un package Dart/Flutter indipendente. `morra_rules` non dipende da Flutter, quindi app e server possono importarlo entrambi.

## Architettura in breve

| Componente    | Scelta                                                                                                    |
| ------------- | --------------------------------------------------------------------------------------------------------- |
| App mobile    | **Flutter / Dart**                                                                                        |
| Backend       | **Serverpod** (Dart): endpoint, ORM, migrazioni, modulo auth, job programmati, streaming                  |
| Database      | **PostgreSQL**                                                                                            |
| Hosting       | Auto-ospitato su SSD Nodes con **Docker Compose**, esposto tramite **Cloudflare Tunnel**                  |
| Motore regole | `packages/morra_rules`, **un'unica implementazione condivisa da app e server**                            |
| Offline       | Punteggi registrati come **eventi** con ID univoco generato dal client, salvati in locale e sincronizzati |
| Console admin | Prevista in Flutter Web con lo stesso client generato (un front end Nuxt resta possibile)                 |
| Push          | Logica sul server, consegna tramite FCM (Android) e APNs (iOS)                                            |

Idee chiave:

- **Offline first.** Si gioca in bar di montagna con poca copertura. L'app conta i punti in locale e sincronizza dopo.
- **Punteggi come eventi.** Ogni tocco registra un evento (punto, abbassamento, annulla). Il punteggio deriva dal registro degli eventi, quindi annulla, storico e ricostruzione della partita sono gratuiti.
- **Il server è l'autorità.** Il client applica le regole in locale per il conteggio live; il server inserisce gli eventi in modo idempotente, li rigioca con lo stesso codice `morra_rules` e pubblica il risultato ufficiale.

## Come iniziare

Requisiti: Flutter SDK (include Dart) e un dispositivo o emulatore Android.

```bash
# motore regole
cd packages/morra_rules
dart pub get
dart test

# app mobile
cd apps/mobile
flutter pub get
flutter run
```

Il backend non è ancora nel repository. Quando ci sarà, la configurazione (Docker Compose con Postgres) sarà documentata in `apps/server/README.md`.

## Roadmap (sintesi)

1. **MVP**: backend, registrazione e ruoli, calendario tappe, prenotazione e check-in QR, conta-partite offline, classifica di tappa.
2. **Torneo live**: abbinamenti automatici, modalità live, classifica di stagione con convalida admin, notifiche.
3. **Comunità**: foto, statistiche, albo d'oro, esportazioni, pagine pubbliche, italiano / francese.

I dettagli sono in [`docs/PROJECT.md`](docs/PROJECT.md).

## Dati e privacy di questo repository

Questo repository **non contiene dati personali reali**. Giocatori, squadre, tappe, risultati, foto e pagamenti usati in test, fixture, screenshot ed esempi sono **interamente fittizi**.

- I dati reali dei giocatori (profili, foto, quote) vivranno solo nel database di produzione sul server auto-ospitato, mai nel repository né nella sua storia.
- I segreti (password, chiavi API, token, file `.env`) non vengono committati. I modelli di configurazione usano segnaposto (ad esempio `.env.example`).
- I dati di seed e di test devono essere inventati. Non incollare nomi, email, numeri di telefono o foto di persone reali.

## Licenza

Vedi [`LICENSE`](LICENSE).
