<a id="english"></a>

[🇬🇧 English](#english) · [🇮🇹 Italiano](#italiano)

# 🤟 Morra Valdostana – Tournament App

> Mobile app (iOS and Android) to organise, play and follow **Morra Valdostana** tournaments: stage calendar, sign-ups with check-in, live standings, a match score counter and season rankings.

**Project status:** early development (offline score counter and rules package exist; backend not started)
**Technology:** Flutter (Dart) · Serverpod (Dart) · PostgreSQL · Docker

---

## Table of contents

1. [Why this project](#why-this-project)
2. [The game and the tournament rules](#the-game-and-the-tournament-rules)
3. [Users and roles](#users-and-roles)
4. [Features](#features)
5. [The score counter](#the-score-counter)
6. [Live tournament and pairings](#live-tournament-and-pairings)
7. [Scoring and rankings](#scoring-and-rankings)
8. [Sign-up, fee and check-in](#sign-up-fee-and-check-in)
9. [Share moments](#share-moments)
10. [Technical architecture](#technical-architecture)
11. [Web admin app and shared backend](#web-admin-app-and-shared-backend)
12. [Data model (draft)](#data-model-draft)
13. [Privacy and legal aspects](#privacy-and-legal-aspects)
14. [Roadmap](#roadmap)
15. [Future ideas](#future-ideas)
16. [Open questions](#open-questions)

---

## Why this project

Morra tournaments are still largely run with pen and paper: scores written by hand, rankings calculated at the end of the evening, communication via chat. The app aims to:

- **make organisers' lives easier** (calendar, sign-ups, pairings, automatic rankings);
- **give players** an always up-to-date ranking, a personal history and stage reminders;
- **work where the game is really played**, i.e. mountain bars and venues where mobile coverage is often poor (_offline-first_ approach);
- **preserve the memory** of the season, with photos, a hall of fame and statistics.

The scale is that of a community: about **100–150 players** per season, with **15–20** people at a typical stage and peaks of **40–60** at the best-attended ones.

---

## The game and the tournament rules

> Note: morra has many local variants and the "local rules" prevail. Everything below is **configurable** in the app, so it can adapt to different seasons, clubs and stages.

### The basic concept: a "hand" of morra

Morra is a game of **intuition and quick reflexes** between **two players** facing each other.

1. **Simultaneously**, each player:
   - shows a number of fingers from **1 to 5** with **one hand**;
   - **calls out loud** a number from **2 to 10**, which is their guess of the **sum** of the fingers shown by both players.
2. The actual sum of the two hands is checked.
3. **The player who guessed the sum** with the number called out **scores a point**.

Special cases:

| Situation                                            | Outcome                                                           |
| ---------------------------------------------------- | ----------------------------------------------------------------- |
| Only one player guesses the sum                      | **+1 point** for that player                                      |
| Nobody guesses                                       | No point, the hand is replayed                                    |
| Both call the **same number** and the sum is correct | **Null point** for both, play simply continues with the next hand |

_Example:_ A shows 3 fingers and calls "7", B shows 2 fingers and calls "5". The sum is 5, so **B** scores. If both had called "5", the point would be null.

A game is a series of hands in which players accumulate points up to the **target score** (normally 16). In tournaments, this duel is part of the pairs format described below.

> In the main version, the app **does not simulate the morra hand**: it counts points and manages the tournament and rankings. The fingers and called numbers stay, as tradition has it, between the players. A simulated game mode is however among the [future ideas](#future-ideas).

#### Which numbers can you call? (a limit on your own call)

The fingers you show also **limit what you can reasonably call**. The opponent shows between 1 and 5 fingers, so the sum can only fall within a range based on **your own** hand:

> **Your fingers + 1 ≤ the sum ≤ Your fingers + 5**

_Example:_ if you show **2 fingers**, the lowest possible sum is 2 + 1 = 3 and the highest is 2 + 5 = 7. So you **cannot call 8**: whatever the opponent shows, 2 plus anything from 1 to 5 can never make 8. Calling it would mean calling a sum that is mathematically impossible.

| You show  | Possible sums | Impossible calls |
| --------- | ------------- | ---------------- |
| 1 finger  | 2 – 6         | 7, 8, 9, 10      |
| 2 fingers | 3 – 7         | 2, 8, 9, 10      |
| 3 fingers | 4 – 8         | 2, 3, 9, 10      |
| 4 fingers | 5 – 9         | 2, 3, 4, 10      |
| 5 fingers | 6 – 10        | 2, 3, 4, 5       |

#### The closed fist counts as 1

Showing a **closed fist** is the same as showing **one finger**: both are worth **1**. There is no "zero" in morra, so the lowest number you can show is always 1.

### How it is played in a tournament

- Played by **four, two against two**: one team on each side of the table.
- Two players facing each other start. When one of them scores, the winner **continues against the other opponent** (so diagonally). If they win again, they play the one in front of them again, otherwise they continue with the other opponent, and so on.
- The app **does not track who plays whom** in the rotation: it only counts the points scored **by the team** (each time a player wins their hand, +1 to their team).

### Points and matches

- A **game** (_partita_) is a contest between the **same two teams**, won by the **first team to reach 16 points** (configurable; on some occasions, e.g. the deciding game, it can be **21**).
- Results such as **3-0, 3-1, 3-2** (used for stage points) describe the overall outcome of the **match** (_incontro_) between the two teams, won by winning 3 games. The first four games target 16 points; only the deciding fifth game at 2-2 targets 21.

### Lowering the hand

Points are counted on the fingers of the left hand (cycles of 5). For this reason, during a game, when the two teams' scores **line up** (tie), both teams' scores can be **"brought down"** and play continues (e.g. 14-14 → 9-9 or 4-4).

- It applies **within a single game** (the same two teams, won by the first to reach 16).
- Each team may do it **only once per game**, so at most **2 times** in the same game.
- Usually the score is lowered by **5 points**, sometimes by **10**, very rarely by **15 or 20**.
- There is no strict rule: the app lets the user **choose the amount** (5/10/15/20) and records it.

---

## Users and roles

| Role                      | What they can do                                                                           |
| ------------------------- | ------------------------------------------------------------------------------------------ |
| **Player (user)**         | Views calendar, rankings and profile; signs up for stages; checks in; shares photos        |
| **Scorekeeper / referee** | Uses the score counter for a game. The role is **enabled by an admin** for that stage/game |
| **Admin / organiser**     | Manages calendar, sign-ups, fees, pairings, ranking validation, photo moderation, roles    |

Registration is open; admin and scorekeeper permissions are granted or confirmed by an admin.

---

## Features

### 👤 Player

- **Calendar** of stages with date, time and venue.
- **Overall season ranking** (who has the most points overall).
- **Personal profile**: photo, info, points, position, statistics.
- **Attendance register** and history of stages played.
- **Booking** for the stage and **QR code check-in**.
- **Notifications**: stage reminders, schedule changes, and an alert when _one person is missing to complete the tables_ (see below).
- **Directions** to the bar or tournament venue (opens in maps).
- **Live mode** during the stage: games in progress, results, provisional ranking.
- **Score counter**, also reachable from the stage's live ranking.
- **Share moments**: send photos to the organisers for the final collection.

### 🛠️ Admin

- **Calendar management** (create, edit, cancel stages).
- **Management of participants**, attendance and fee payment.
- **Live mode**: automatic generation of pairings (baraonda or fixed pairs).
- **Ranking validation**: calculated automatically, then checked and made official by the admin.
- **Scorekeeper authorisation**.
- **Configurable rules** per season and per stage.
- **Moderation** of uploaded photos.

### ✨ Planned extras

- Personal statistics (win rate, most frequent partners and opponents, season trend).
- **Hall of fame** of past seasons.
- Export of rankings and results (PDF/CSV).
- Full-screen **"projection"** view for the live ranking on the venue's TV.
- **Italian and French** interface.
- Score change history (who changed what and when).

---

## The score counter

A simple and fast screen, designed to be used at the table even with one hand.

- **Two large buttons**, one per team, to increase the score (+1).
- **Undo last point**.
- **Lower the hand**, with a choice of amount (5 / 10 / 15 / 20), valid **once per team per game** (configurable limit). If the two teams are tied, both scores are reduced by the same amount and the game continues from there.
- **Alert** when the two teams' scores line up during the game (the situation in which the hand can be lowered).
- Automatic handling of **game** and **match**: when a team reaches the target score it wins the game; on the third game won it wins the match.
- Works **offline**: data syncs as soon as the connection returns.
- Reachable from the stage's **live ranking**.

### Design principle: scores as events

Each tap does not change a number, but records an **event** ("team 1 +1", "team 2 lowers by 5"). The score is the sum of events. This allows:

- working offline and syncing without conflicts;
- undo and full history for free;
- settling disputes by replaying the game.

The event contract is designed for syncing with a server:

- a **globally unique ID** generated on the device (UUID, ideally time-ordered), plus the game and device it belongs to;
- a **sequence number per game** and a client timestamp, so the server can order events and detect gaps;
- a **pure "apply" function** (state + event → new state or error) used both when the user taps and when the whole log is replayed and validated;
- undo as a rule that stays consistent: either only the last active event can be undone, or the whole sequence is revalidated after an undo.

---

## Live tournament and pairings

The admin starts **live mode** for the stage. The app generates pairings in two modes:

### Baraonda

Pairs are drawn at each round, **avoiding as far as possible** repeating the same partners and the same opponents. Points go to **individual players**. Final phases (final, semi-finals, etc.) can also award prizes to teams.

### Stage structure: qualifications and final phase

A stage is always divided into two parts:

1. **Qualifications**, with baraonda draws organised in groups.
2. **Knockout phase**, calculated from the number of participants: round of 16,
   quarter-finals, semi-finals and final. If there are few participants,
   unnecessary initial rounds are omitted. The bracket follows a power of two
   (`2^n`).

The baraonda draw rules are:

- **Up to 19 players**: 5 games are played, drawing the pair each time. The
  top 8 players advance to the semi-finals, where pairs are drawn again. In
  case of a tie for eighth place, the younger player advances.
- **20 players**: 2 groups of 5 pairs; the top 4 pairs from each group advance
  to the quarter-finals.
- **22 players**: groups of 6 and 5 pairs; the top 4 pairs from each group
  advance.
- **24 players**: 2 groups of 6 pairs; the top 4 pairs from each group
  advance.
- **26 players**: groups of 5, 4 and 4 pairs; the top 3 from the group of 5
  and top 2 from each group of 4 advance. The third-placed pairs from the
  groups of 4 play a tie-break for the final quarter-final place.
- **28 players**: groups of 5, 5 and 4 pairs; the top 3 pairs from each group
  of 5 and top 2 from the group of 4 advance.
- **30 players**: 3 groups of 5 pairs; the top 2 from each group advance. The
  third-placed pairs play a three-pair mini-tournament, from which the top 2
  advance.
- **32 players**: 4 groups of 4 pairs; the top 2 pairs from each group
  advance to the quarter-finals.

### Fixed pairs (coppia fissa)

Pairs are decided in advance and stay the same for the whole stage. Points go to the **pair**, which is rewarded as such.

### When the number of players is not a multiple of 4

Since the game is played by four, a number of players that is not a multiple of 4 leaves a **remainder**. The admin can choose how to handle it:

1. **Individual 1-vs-1 play-off** between the players left out (the preferred
   option).
2. **Walkover win ("lucky one")**: one or more players are awarded a won game,
   assigned **in a fair rotation** so it is not always the same person who
   benefits.

The method is a configurable setting of the stage and can be selected by an
admin.

### "One missing" alert

During the booking phase, if the number of sign-ups is unfavourable (remainder different from 0) and **one or a few more people are enough** to form all the tables, the app can **send a notification** to the other players. To avoid spam, sending is limited (time threshold and maximum number of alerts).

---

## Scoring and rankings

### Stage points (configurable)

| Match result | Points to each member of the winning team | Losers      |
| ------------ | ----------------------------------------- | ----------- |
| 3-0          | **3 points**                              | 0           |
| 3-1          | **3 points**                              | 0           |
| 3-2          | **2 points**                              | **1 point** |

_Example:_ if team A wins 3-0, **both** players of A receive 3 points.

### Stage ranking

- At the end of the day, each player's points (baraonda) or each pair's points (fixed pairs) are summed.
- **1st, 2nd, 3rd and 4th place** are awarded (number of prize places configurable based on participants).
- In baraonda, **teams** that reached the final, semi-final, etc. can also be rewarded.

### Overall season ranking

- Sum of the points obtained across all stages.
- Planned options: dropping the worst results, tie-break criteria, categories.
- **Automatic** calculation, then **validated by the admin** before official publication.

---

## Sign-up, fee and check-in

1. The player **books** their participation in the stage from the app.
2. On tournament day, at the venue, they **check in with a QR code** (scanned by the admin or on the admin's device).
3. At check-in, the **entry fee payment** is recorded: **€10** per stage (configurable amount).
4. Check-in confirms **attendance** and feeds the attendance register and the list of players on which pairings are calculated.

> The payment is **recorded** in the app (paid / not paid) but, for now, is not handled online: it is collected on site. Possible integration with digital payments is postponed to a later phase.

---

## Share moments

A section where each player can **send photos** taken during the tournament to the organisers, to build a **big final collection** of the season.

- Upload from the app with automatic image compression.
- **Moderation**: the admin approves photos before publication.
- Gallery per stage and a final season collection.
- **Explicit consent** to submission and publication (recognisable people in the images) and the possibility to request removal.

---

## Technical architecture

### Proposed stack

The backend is a **Serverpod** server (Dart), **self-hosted** on an own server (SSD Nodes) with Docker Compose and exposed through **Cloudflare Tunnel**. It serves the mobile app and the web admin app.

| Component               | Choice                                                                                                               |
| ----------------------- | -------------------------------------------------------------------------------------------------------------------- |
| Mobile app              | **Flutter / Dart** (iOS + Android)                                                                                   |
| State management        | Riverpod (or Bloc)                                                                                                   |
| Backend / API           | **Serverpod** (Dart): typed endpoints, generated client for Flutter, ORM                                             |
| Database                | **PostgreSQL**, with Serverpod ORM and migrations                                                                    |
| Rules engine            | Shared Dart package `morra_rules`, imported by both app and server                                                   |
| Local mobile storage    | SQLite (e.g. Drift) for **offline use**, synced with the server                                                      |
| Authentication          | Serverpod auth module (email + password), roles stored in the database; check the current module docs                |
| Real time               | Serverpod streaming (WebSocket) for live rankings and results                                                        |
| Files (photos, avatars) | Serverpod file uploads, with S3-compatible storage (e.g. MinIO) or database storage, always behind the API           |
| Push notifications      | Logic on the own server; delivery through FCM (Android) and APNs (iOS), which are required for phone push            |
| Scheduled jobs          | Serverpod future calls (ranking recalculation, reminders, "one missing" alerts)                                      |
| Web admin app           | Flutter Web using the same generated client (to be confirmed, see [next section](#web-admin-app-and-shared-backend)) |
| Hosting                 | Docker Compose (API, PostgreSQL, cloudflared) on the own server                                                      |

_Why Serverpod:_ one language across app, server and rules; a client generated from the server code (no hand-written REST layer, fewer app/server mismatches); ORM, migrations, auth, streaming and scheduled jobs included, which matters for a single developer. _Trade-offs:_ an opinionated framework with some lock-in, and a generated client designed for Dart/Flutter. If a non-Dart front end is needed later, REST endpoints can be exposed alongside.

_Alternatives considered:_ Shelf or Dart Frog with hand-written SQL (maximum control, much more code to write: auth, migrations, jobs); a TypeScript backend (Nuxt/Node with Prisma), which would need a second implementation of the rules engine; Firebase or Supabase (managed, less maintenance but less control). With these user volumes, costs would be negligible in any case; the self-hosted choice trades some maintenance work (backups, updates, monitoring) for full control and no vendor lock-in.

### Repository layout

One monorepo, with independent packages:

```
morra_vda/
 ├─ apps/
 │   ├─ mobile/            # Flutter app
 │   └─ server/            # Serverpod server
 ├─ packages/
 │   ├─ morra_rules/       # RULES ENGINE (pure Dart, no Flutter dependencies)
 │   │    ├─ scoring/         # score counter, lowering the hand, game/match victory
 │   │    ├─ pairing/         # baraonda / fixed-pairs pairings, remainder handling
 │   │    └─ ranking/         # stage points and season ranking
 │   └─ morra_client/      # client generated by Serverpod
 └─ docs/
     └─ PROJECT.md
```

Inside the mobile app the code is layered:

```
apps/mobile/lib/
 ├─ presentation/   # screens and widgets
 ├─ application/    # use cases, state management
 └─ data/           # generated API client, local SQLite, offline sync
```

The **rules engine** is the most delicate part: it is kept as pure Dart code, in its own package, and covered by **automated tests**, so it can be verified against real cases (ties, lowering, remainders, play-offs) without launching the app or the server.

### Security

- Role-based authorisation on the server (player / scorekeeper / admin); optionally PostgreSQL row-level security.
- Only admins and authorised scorekeepers can write scores; the client is never trusted.
- Audit log for every change to results.

---

## Web admin app and shared backend

Besides the mobile app, the project includes a **web management app** (admin console) that uses the **same server and the same database**. Organisers can run the season comfortably from a PC, while players keep using the mobile app.

The current plan is to build it in **Flutter Web**, reusing the generated client, the rules package and the Dart skills already needed for the app. A separate web front end (for example Nuxt) remains possible later, calling REST endpoints exposed by the server; this is an open question.

### Why a web app

- Faster and more comfortable for **data entry and management** on a large screen (calendar, participants, payments, roles).
- Better for **validation and moderation** tasks (rankings, photos) and for **exports**.
- A web page is the natural choice for the **projection view** of the live ranking on the venue's TV (just open a URL).
- Optional **public read-only pages** (calendar, rankings, hall of fame) shareable with anyone, with no app or account.

### Web features

- **Admin dashboard**: next stage, sign-ups, check-ins, fees collected.
- **Calendar management**: create, edit, cancel stages; venue and directions.
- **Participants**: lists, attendance register, fee status, manual check-in.
- **Roles**: promote players to scorekeeper or admin.
- **Live tournament control**: generate pairings, handle the remainder, follow games in progress.
- **Ranking validation**: review the automatic calculation and publish it as official.
- **Rules configuration** per season and stage (points, targets, lowering the hand, prizes).
- **Photo moderation** and final season gallery.
- **Exports** (PDF/CSV) and **projection view** for the TV.
- **Audit log** of changes to results.

### Overall architecture

```
 Flutter app (iOS / Android)        Admin web (Flutter Web, + public pages)
        │  local SQLite (offline)               │
        └──────────────┬────────────────────────┘
                       │  generated client, HTTPS / WebSocket
              Cloudflare Tunnel (TLS, DNS)
                       │
              ┌────────┴─────────┐   Own server (SSD Nodes, Docker Compose)
              │ Serverpod server │   uses morra_rules
              ├──────────────────┤
              │   PostgreSQL     │   files   scheduled jobs (future calls)
              └──────────────────┘
                       │
              FCM / APNs (push delivery only)
```

### Offline sync

The mobile app records scores as **events** with a client-generated unique ID, a sequence number per game and a timestamp. When the connection returns, events are sent to the server, which:

1. **inserts them idempotently** (no duplicates if sent twice);
2. **replays the whole log** of the game with the shared rules engine, validating every event (tie required to lower the hand, once per team, game already finished, and so on);
3. stores the resulting state as the official one and updates the live views through streaming.

If the replay fails, the game is not discarded: it is flagged **"to verify"** for an admin, because in a bar without coverage a whole evening of scores must never be lost. Because events are append-only, conflicts are rare and the game can always be reconstructed.

### One rules engine

The rules engine is a single Dart package, `morra_rules`, imported by the mobile app (live scoring, also offline) and by the Serverpod server (validation, pairings, stage points, rankings). There is no second implementation to keep aligned, so the app and the server cannot drift apart. The server remains the authority: the app applies the rules locally only so that it works without a connection.

### Operations on a self-hosted server

- **Docker Compose**: PostgreSQL, the Serverpod server and `cloudflared`. Database and server publish no ports to the host; the only way in is the tunnel, which exposes just the public API port. The monitoring/Insights port is not published.
- **Migrations**: created with the Serverpod tooling and applied at server start; never edit the schema by hand.
- **Backups**: scheduled PostgreSQL dumps, stored also **off the server**, with a restore test.
- **Monitoring and updates**: uptime check, logs, regular OS, image and dependency updates.
- **Security**: HTTPS through Cloudflare, secrets and password files kept out of the repository, rate limiting, **Cloudflare Access** in front of the admin console.
- **Environments**: a separate test environment to try rules changes before a real stage.
- **Availability**: thanks to offline-first, a short server outage does not stop a tournament.

---

## Data model (draft)

Defined as Serverpod models, which generate the tables, migrations and client classes.

- **users**: profile, role, photo, consents
- **seasons**: season, rules (`RuleSet`), status
- **tournaments (stages)**: date, venue, mode (baraonda / fixed pairs), status (scheduled / live / closed / validated)
- **registrations**: player, stage, booking status, check-in, fee paid
- **matches**: stage, teams, players, status (including "to verify"), final result
- **match_events**: scoring events (id, game, sequence, device, type, payload)
- **standings**: stage and season rankings (calculated, then validated)
- **photos**: author, stage, moderation status
- **audit_log**: changes to results

---

## Privacy and legal aspects

- **GDPR**: privacy notice, explicit consents (profile, photos), right of access and deletion.
- **Minors**: if allowed, they require the consent of the person with parental responsibility.
- **Account deletion** directly from the app (required by the stores).
- **Self-hosted data**: location of the server and backups, access control, retention periods and a data-breach procedure to be documented.
- **Sign in with Apple** mandatory on iOS if other social logins are offered.
- **Photos**: consent to publication and a removal procedure.
- **Entry fees**: check with the organisation for any tax or association obligations.
- **This repository contains no real personal data**: all sample data, fixtures and screenshots are fictitious, and real player data lives only in the production database. Secrets are never committed (placeholders such as `.env.example` are used).

---

## Roadmap

**Phase 1 – MVP**

- Serverpod server + PostgreSQL in Docker on the own server
- Rules package hardening: unique event IDs, sequence numbers, validated replay
- Registration and roles
- Stage calendar
- Booking and QR check-in (with fee recording)
- **Offline score counter** with sync
- Stage ranking
- **Web admin (basic)**: calendar, participants, roles

**Phase 2 – Live tournament**

- Automatic pairings (baraonda and fixed pairs, remainder handling)
- Live mode and provisional ranking
- Season ranking with admin validation
- **Web admin**: live control, validation, rules configuration
- Notifications (reminders and "one missing")

**Phase 3 – Community**

- Share moments
- Statistics, hall of fame
- PDF/CSV exports, projection screen (web)
- **Public web pages** (calendar, rankings, hall of fame), photo moderation
- Italian / French

---

## Future ideas

### 1. "Light" version without registration

A version (or mode) of the app that can be **used without creating an account**, for people who just want to try the game or use the basic tools.

- **Includes**: score counter (also for friendly games outside tournaments), game rules, bot mini-game (see below), public access to the calendar and the overall ranking.
- **Does not include**: profile, stage sign-up, check-in, personal notifications, statistics stored in the cloud, photo sharing.
- **Data**: stored only **locally** on the device, with no personal data collection (also a privacy advantage).
- **Upgrade to the full version**: the option to register later, carrying the local history over to the account.
- **Goal**: lower the entry barrier, introduce the game to new players and tourists, and act as a "showcase" for the community.

### 2. Morra mini-game against bots

A **fun game inside the app** that simulates real morra, playable **alone against bots** (and online in the future).

- **Basic mechanics**: on each hand the player chooses fingers (1–5) and calls the sum (2–10); the bot does the same simultaneously. The same rules as the real game apply, including the null point when both called numbers coincide.
- **Format**: game to 16 points, with the option to **lower the hand** as in the real game.
- **Bots with personality**: different levels and styles (cautious, aggressive, "always calls the same number", etc.), for variety and a bit of challenge.
- **Pairs mode**: 2 vs 2 with bot partners, to reproduce the tournament format.
- **Online** (later phase): matches between real players, possibly with a dedicated leaderboard and remote friendlies.
- **Purpose**: practise, learn the rules in a fun way, draw younger people to the traditional game and keep the app alive outside stage days.
- **Technical aspects**: the simulation reuses the same `morra_rules` package (scoring, lowering, game victory), plus the bot logic.

### 3. Other ideas to evaluate

- Interactive **tutorial** mode to learn how to play.
- **Achievements and badges** (also for the mini-game).
- Link between the mini-game and the profile for account holders (statistics separate from real tournaments).

---

## Open questions

- **Season ranking**: dropped results, tie-break criteria, possible categories.
- **€10 fee**: possible handling of discounts, freebies or advance payments.
- **Languages**: Italian and French, and consider adding Patois.
- **Handling of minors** and the data controller.
- **Admin front end**: Flutter Web only, or a separate web app (e.g. Nuxt) calling REST endpoints; and whether to offer public read-only pages.
- **Authentication and file storage**: which Serverpod auth options to enable (email only, or also social logins) and where to store photos.
- **Undo rule**: only the last active event, or revalidation of the whole sequence.
- **Backups and hosting**: where to keep off-server copies and who is responsible for maintenance.

---

_Project design document._

---

---

<a id="italiano"></a>

[🇬🇧 English](#english) · [🇮🇹 Italiano](#italiano)

# 🤟 Morra Valdostana – App per i tornei

> App mobile (iOS e Android) per organizzare, giocare e seguire i tornei di **Morra Valdostana**: calendario delle tappe, iscrizioni con check-in, classifica live, conta-partite e classifica di stagione.

**Stato del progetto:** sviluppo iniziale (esistono il conta-partite offline e il package delle regole; il backend non è iniziato)
**Tecnologia:** Flutter (Dart) · Serverpod (Dart) · PostgreSQL · Docker

---

## Indice

1. [Perché questo progetto](#perché-questo-progetto)
2. [Il gioco e le regole del torneo](#il-gioco-e-le-regole-del-torneo)
3. [Utenti e ruoli](#utenti-e-ruoli)
4. [Funzionalità](#funzionalità)
5. [Il conta-partite](#il-conta-partite)
6. [Torneo live e abbinamenti](#torneo-live-e-abbinamenti)
7. [Punteggi e classifiche](#punteggi-e-classifiche)
8. [Iscrizione, quota e check-in](#iscrizione-quota-e-check-in)
9. [Condividi momenti](#condividi-momenti)
10. [Architettura tecnica](#architettura-tecnica)
11. [App gestionale web e backend condiviso](#app-gestionale-web-e-backend-condiviso)
12. [Modello dati (bozza)](#modello-dati-bozza)
13. [Privacy e aspetti legali](#privacy-e-aspetti-legali)
14. [Roadmap](#roadmap)
15. [Idee future](#idee-future)
16. [Punti ancora da definire](#punti-ancora-da-definire)

---

## Perché questo progetto

I tornei di morra si organizzano ancora in gran parte con carta e penna: punteggi segnati a mano, classifiche calcolate a fine serata, comunicazioni via chat. L'app nasce per:

- **semplificare la vita agli organizzatori** (calendario, iscrizioni, abbinamenti, classifiche automatiche);
- **dare ai giocatori** una classifica sempre aggiornata, uno storico personale e promemoria sulle tappe;
- **funzionare nei posti reali in cui si gioca**, cioè bar e locali di montagna dove spesso la copertura di rete è scarsa (approccio _offline-first_);
- **conservare la memoria** della stagione, con foto, albo d'oro e statistiche.

L'ordine di grandezza è quello di una comunità: circa **100–150 giocatori** a stagione, con **15–20** persone a una tappa normale e punte di **40–60** nelle tappe più partecipate.

---

## Il gioco e le regole del torneo

> Nota: la morra ha molte varianti locali e il "regolamento locale" prevale. Tutto ciò che segue è **configurabile** nell'app, così da adattarsi a stagioni, circoli e tappe diverse.

### Il concetto base: una "mano" di morra

La morra è un gioco di **intuito e prontezza** tra **due giocatori** che si sfidano faccia a faccia.

1. **Contemporaneamente**, ciascun giocatore:
   - mostra con **una mano** un numero di dita da **1 a 5**;
   - **dice a voce** un numero da **2 a 10**, cioè la propria previsione della **somma** delle dita mostrate da entrambi.
2. Si controlla la somma reale delle due mani.
3. **Fa punto chi ha indovinato la somma** con il numero detto a voce.

Casi particolari:

| Situazione                                                 | Esito                                                                         |
| ---------------------------------------------------------- | ----------------------------------------------------------------------------- |
| Un solo giocatore indovina la somma                        | **+1 punto** a lui                                                            |
| Nessuno indovina                                           | Nessun punto, si ripete la mano                                               |
| Entrambi dicono lo **stesso numero** e la somma è corretta | **Punto nullo** per entrambi, si procede semplicemente con la mano successiva |

_Esempio:_ A mostra 3 dita e dice "7", B mostra 2 dita e dice "5". La somma è 5, quindi fa punto **B**. Se invece entrambi avessero detto "5", il punto sarebbe nullo.

Una partita è una successione di mani in cui i giocatori accumulano punti fino al **punteggio target** (di norma 16). Nel torneo questo duello si inserisce nel formato a coppie descritto qui sotto.

> Nella versione principale l'app **non simula la mano di morra**: serve a contare i punti, gestire il torneo e le classifiche. Le dita e i numeri detti restano, come da tradizione, tra i giocatori. Una modalità di gioco simulata è però tra le [idee future](#idee-future).

#### Quali numeri si possono dire? (un limite sul proprio numero)

Le dita che mostri **limitano anche il numero che ha senso dire**. L'avversario mostra da 1 a 5 dita, quindi la somma può cadere solo in un intervallo che dipende dalla **tua** mano:

> **Le tue dita + 1 ≤ somma ≤ Le tue dita + 5**

_Esempio:_ se mostri **2 dita**, la somma minima possibile è 2 + 1 = 3 e la massima è 2 + 5 = 7. Quindi **non puoi dire 8**: qualunque cosa mostri l'avversario, 2 più un numero da 1 a 5 non potrà mai fare 8. Dire 8 significherebbe chiamare una somma matematicamente impossibile.

| Mostri | Somme possibili | Chiamate impossibili |
| ------ | --------------- | -------------------- |
| 1 dito | 2 – 6           | 7, 8, 9, 10          |
| 2 dita | 3 – 7           | 2, 8, 9, 10          |
| 3 dita | 4 – 8           | 2, 3, 9, 10          |
| 4 dita | 5 – 9           | 2, 3, 4, 10          |
| 5 dita | 6 – 10          | 2, 3, 4, 5           |

#### Il pugno chiuso vale 1

Mostrare il **pugno chiuso** equivale a mostrare **un dito**: entrambi valgono **1**. Nella morra non esiste lo "zero", quindi il numero più basso che si può mostrare è sempre 1.

### Come si gioca in torneo

- Si gioca in **quattro, due contro due**: una squadra da un lato del tavolo, l'altra dall'altro.
- Iniziano due giocatori frontali. Quando uno dei due fa punto, il vincitore **prosegue contro l'altro avversario** (quindi in diagonale). Se vince ancora, torna a giocare con quello di fronte, altrimenti continua con l'altro avversario, e così via.
- L'app **non traccia chi gioca contro chi** nella rotazione: conta solo i punti fatti **dalla squadra** (ogni volta che un giocatore vince la sua mano, +1 alla sua squadra).

### Punti e partite

- Una **partita** è una sfida tra le **stesse due squadre** e la vince la **prima squadra che arriva a 16 punti** (valore configurabile; in alcune occasioni, ad esempio la "bella", può arrivare a **21**).
- I risultati del tipo **3-0, 3-1, 3-2** (usati per i punti di tappa) descrivono l'esito complessivo dell'**incontro** tra le due squadre, che si vince arrivando a 3 partite. Le prime quattro partite hanno obiettivo 16; solo la quinta decisiva sul 2-2 ha obiettivo 21.

### Abbassare la mano

I punti si contano con le dita della mano sinistra (cicli di 5). Per questo, durante una partita, quando i punteggi delle due squadre **si allineano** (parità), si può **"buttare giù" il punteggio di entrambe** e continuare a giocare (ad esempio 14-14 → 9-9 oppure 4-4).

- Vale **dentro la singola partita** (le stesse due squadre, vinta dalla prima che arriva a 16).
- Ogni squadra può farlo **una sola volta per partita**, quindi al massimo **2 volte** nella stessa partita.
- Di solito si abbassa di **5 punti**, a volte di **10**, molto raramente di **15 o 20**.
- Non esiste una regola rigida: l'app lascia **scegliere l'entità dell'abbassamento** (5/10/15/20) e la registra.

---

## Utenti e ruoli

| Ruolo                     | Cosa può fare                                                                                             |
| ------------------------- | --------------------------------------------------------------------------------------------------------- |
| **Giocatore (user)**      | Vede calendario, classifiche e profilo; si iscrive alle tappe; fa check-in; condivide foto                |
| **Segnapunti / arbitro**  | Usa il conta-partite per una partita. Il ruolo **è abilitato da un admin** per quella tappa/partita       |
| **Admin / organizzatore** | Gestisce calendario, iscrizioni, quote, abbinamenti, convalida delle classifiche, moderazione foto, ruoli |

La registrazione è aperta; i permessi di admin e segnapunti vengono assegnati o confermati da un admin.

---

## Funzionalità

### 👤 Giocatore

- **Calendario** delle tappe con data, orario e luogo.
- **Classifica generale** di stagione (chi ha più punti in assoluto).
- **Profilo personale**: foto, informazioni, punti, posizione, statistiche.
- **Registro presenze** e storico delle tappe giocate.
- **Prenotazione** alla tappa e **check-in con QR code**.
- **Notifiche**: promemoria della tappa, cambi di programma, e avviso quando _manca una persona per completare i tavoli_ (vedi sotto).
- **Indicazioni** per raggiungere il bar o il luogo del torneo (apertura nelle mappe).
- **Modalità live** durante la tappa: partite in corso, risultati, classifica provvisoria.
- **Conta-partite**, accessibile anche dalla classifica live della tappa.
- **Condividi momenti**: invio foto all'organizzazione per la raccolta finale.

### 🛠️ Admin

- **Gestione del calendario** (creazione, modifica, annullamento tappe).
- **Gestione iscritti**, presenze e pagamento della quota.
- **Modalità live**: generazione automatica degli abbinamenti (baraonda o coppia fissa).
- **Convalida della classifica**: viene calcolata automaticamente, l'admin la verifica e la rende ufficiale.
- **Abilitazione dei segnapunti**.
- **Regolamento configurabile** per stagione e per tappa.
- **Moderazione** delle foto caricate.

### ✨ Extra pianificati

- Statistiche personali (percentuale di vittorie, compagni e avversari più frequenti, andamento stagionale).
- **Albo d'oro** delle stagioni passate.
- Esportazione di classifiche e risultati (PDF/CSV).
- Schermata **"proiezione"** a tutto schermo per la classifica live sul televisore del locale.
- Interfaccia in **italiano e francese**.
- Storico delle modifiche ai punteggi (chi ha cambiato cosa e quando).

---

## Il conta-partite

Schermata semplice e veloce, pensata per essere usata al tavolo anche con una mano sola.

- **Due grandi pulsanti**, uno per squadra, per incrementare il punteggio (+1).
- **Annulla ultimo punto**.
- **Abbassa la mano**, con scelta dell'entità (5 / 10 / 15 / 20), valida **una volta per squadra e per partita** (limite configurabile). Se le due squadre sono in parità, il punteggio di entrambe viene ridotto dello stesso valore e la partita prosegue da lì.
- **Alert** quando i punteggi delle due squadre si allineano durante la partita (situazione in cui si può abbassare la mano).
- Gestione automatica di **partita** e **incontro**: quando una squadra arriva al punteggio target vince la partita; alla terza partita vinta vince l'incontro.
- Funziona **senza connessione**: i dati si sincronizzano appena torna la rete.
- Accessibile dalla **classifica live** della tappa.

### Principio di progetto: punteggi come eventi

Ogni tocco non modifica un numero, ma registra un **evento** ("squadra 1 +1", "squadra 2 abbassa di 5"). Il punteggio è la somma degli eventi. Questo permette di:

- funzionare offline e sincronizzare senza conflitti;
- avere annulla e storico completo gratuitamente;
- risolvere contestazioni ricostruendo la partita.

Il formato degli eventi è pensato per la sincronizzazione con un server:

- un **ID univoco globale** generato sul dispositivo (UUID, meglio se ordinabile nel tempo), più la partita e il dispositivo di appartenenza;
- un **numero d'ordine per partita** e un timestamp del client, così il server può ordinare gli eventi e rilevare i buchi;
- una **funzione "apply" pura** (stato + evento → nuovo stato oppure errore), usata sia quando l'utente tocca sia quando si rigioca e si convalida l'intero registro;
- una regola di annullamento coerente: o si annulla solo l'ultimo evento attivo, oppure si rivalida l'intera sequenza dopo l'annullo.

---

## Torneo live e abbinamenti

L'admin avvia la **modalità live** per la tappa. L'app genera gli abbinamenti in due modalità:

### Baraonda

Le coppie si formano a sorteggio a ogni turno, **evitando per quanto possibile** di ripetere gli stessi compagni e gli stessi avversari. I punti vanno ai **singoli giocatori**. Le fasi finali (finale, semifinali, ecc.) possono assegnare premi anche alle squadre.

### Struttura della tappa: qualificazioni e fase finale

Una tappa è sempre divisa in due parti:

1. **Qualificazioni**, con sorteggi a baraonda organizzati in gironi.
2. **Fase a eliminazione diretta**, calcolata in base al numero di partecipanti:
   ottavi, quarti, semifinali e finale. Se i partecipanti sono pochi, si
   omettono le fasi iniziali non necessarie. Il tabellone segue una potenza di
   due (`2^n`).

Il regolamento dei sorteggi a baraonda è il seguente:

- **Fino a 19 giocatori**: si disputano 5 partite, sorteggiando ogni volta la
  coppia. I primi 8 giocatori accedono alle semifinali, dove le coppie vengono
  sorteggiate nuovamente. In caso di parità all'ottavo posto, passa il turno il
  giocatore più giovane.
- **20 giocatori**: 2 gironi da 5 coppie; accedono ai quarti le prime 4 coppie
  di ogni girone.
- **22 giocatori**: un girone da 6 coppie e uno da 5; accedono ai quarti le
  prime 4 coppie di ogni girone.
- **24 giocatori**: 2 gironi da 6 coppie; accedono ai quarti le prime 4 coppie
  di ogni girone.
- **26 giocatori**: un girone da 5 coppie e due da 4; accedono ai quarti le
  prime 3 del girone da 5 e le prime 2 dei gironi da 4. Le terze classificate
  dei gironi da 4 disputano uno spareggio per l'ultimo posto ai quarti.
- **28 giocatori**: due gironi da 5 coppie e uno da 4; accedono ai quarti le
  prime 3 coppie dei gironi da 5 e le prime 2 del girone da 4.
- **30 giocatori**: 3 gironi da 5 coppie; accedono ai quarti le prime 2 di ogni
  girone. Le terze disputano un mini torneo a 3 coppie, dal quale passano le
  prime 2.
- **32 giocatori**: 4 gironi da 4 coppie; accedono ai quarti le prime 2 coppie
  di ogni girone.

### Coppia fissa

Le coppie sono decise in anticipo e restano uguali per tutta la tappa. I punti vanno alla **coppia**, che viene premiata come tale.

### Quando i giocatori non sono multipli di 4

Poiché si gioca in 4, un numero di giocatori non multiplo di 4 lascia un **resto**. L'admin può scegliere come gestirlo:

1. **Vittoria a tavolino ("fortunato")**: uno o più giocatori ricevono una partita vinta, assegnati **a rotazione equa**, così non è sempre lo stesso a beneficiarne.
2. **Spareggio individuale 1 contro 1** tra i giocatori rimasti fuori.

Il metodo è una scelta configurabile della tappa.

### Avviso "ne manca uno"

Durante la fase di prenotazione, se il numero di iscritti non è favorevole (resto diverso da 0) e **basta una o poche persone in più** per formare tutti i tavoli, l'app può **inviare una notifica** agli altri giocatori. Per evitare l'effetto spam, l'invio è limitato (soglia temporale e numero massimo di avvisi).

---

## Punteggi e classifiche

### Punti di tappa (configurabili)

| Risultato incontro | Punti a ciascun componente della squadra vincente | Perdenti    |
| ------------------ | ------------------------------------------------- | ----------- |
| 3-0                | **3 punti**                                       | 0           |
| 3-1                | **3 punti**                                       | 0           |
| 3-2                | **2 punti**                                       | **1 punto** |

_Esempio:_ se la squadra A vince 3-0, **entrambi** i giocatori di A ricevono 3 punti.

### Classifica di tappa

- A fine giornata si sommano i punti di ogni giocatore (baraonda) o di ogni coppia (coppia fissa).
- Si assegnano **1°, 2°, 3° e 4° posto** (numero di premiati configurabile in base ai partecipanti).
- In baraonda si possono premiare anche le **squadre** arrivate in finale, semifinale, ecc.

### Classifica generale di stagione

- Somma dei punti ottenuti in tutte le tappe.
- Opzioni previste: scarto dei peggiori risultati, criteri di spareggio, categorie.
- Calcolo **automatico**, poi **convalidato dall'admin** prima della pubblicazione ufficiale.

---

## Iscrizione, quota e check-in

1. Il giocatore **prenota** la partecipazione alla tappa dall'app.
2. Il giorno del torneo, presso il locale, fa **check-in con QR code** (scansionato dall'admin o dal suo dispositivo).
3. Al check-in viene registrato il **pagamento della quota di iscrizione**, che per ogni tappa è di **10 €** (importo configurabile).
4. Il check-in conferma la **presenza** e alimenta il registro presenze e l'elenco dei giocatori su cui calcolare gli abbinamenti.

> Il pagamento viene **registrato** nell'app (pagato / non pagato) ma, per ora, non è gestito online: l'incasso avviene sul posto. Un'eventuale integrazione con pagamenti digitali è rimandata a una fase successiva.

---

## Condividi momenti

Sezione dove ogni giocatore può **inviare foto** scattate durante il torneo all'organizzazione, per creare una **grande raccolta finale** della stagione.

- Caricamento dall'app con compressione automatica delle immagini.
- **Moderazione**: l'admin approva le foto prima della pubblicazione.
- Gallery per tappa e raccolta finale di stagione.
- **Consenso esplicito** all'invio e alla pubblicazione (persone riconoscibili nelle immagini) e possibilità di richiedere la rimozione.

---

## Architettura tecnica

### Stack proposto

Il backend è un server **Serverpod** (Dart), **auto-ospitato** su un server proprio (SSD Nodes) con Docker Compose ed esposto tramite **Cloudflare Tunnel**. Serve l'app mobile e l'app gestionale web.

| Componente             | Scelta                                                                                                                        |
| ---------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| App mobile             | **Flutter / Dart** (iOS + Android)                                                                                            |
| Gestione stato         | Riverpod (o Bloc)                                                                                                             |
| Backend / API          | **Serverpod** (Dart): endpoint tipizzati, client generato per Flutter, ORM                                                    |
| Database               | **PostgreSQL**, con ORM e migrazioni di Serverpod                                                                             |
| Motore regole          | Package Dart condiviso `morra_rules`, importato sia dall'app sia dal server                                                   |
| Archivio locale mobile | SQLite (es. Drift) per l'**uso offline**, sincronizzato con il server                                                         |
| Autenticazione         | Modulo auth di Serverpod (email + password), ruoli salvati nel database; verificare la documentazione attuale                 |
| Tempo reale            | Streaming di Serverpod (WebSocket) per classifiche e risultati live                                                           |
| File (foto, avatar)    | Upload di Serverpod, con storage compatibile S3 (es. MinIO) oppure nel database, sempre dietro l'API                          |
| Notifiche push         | Logica sul server proprio; consegna tramite FCM (Android) e APNs (iOS), necessari per le push su telefono                     |
| Job programmati        | Future call di Serverpod (ricalcolo classifiche, promemoria, avvisi "ne manca uno")                                           |
| App gestionale web     | Flutter Web con lo stesso client generato (da confermare, vedi [sezione successiva](#app-gestionale-web-e-backend-condiviso)) |
| Hosting                | Docker Compose (API, PostgreSQL, cloudflared) sul server proprio                                                              |

_Perché Serverpod:_ un solo linguaggio per app, server e regole; un client generato dal codice del server (niente livello REST scritto a mano, meno disallineamenti tra app e server); ORM, migrazioni, auth, streaming e job programmati inclusi, il che conta per un singolo sviluppatore. _Compromessi:_ un framework con le sue convenzioni e un certo vincolo, e un client generato pensato per Dart/Flutter. Se in futuro servisse un front end non Dart, si possono esporre anche endpoint REST.

_Alternative valutate:_ Shelf o Dart Frog con SQL scritto a mano (massimo controllo, molto più codice da scrivere: auth, migrazioni, job); un backend TypeScript (Nuxt/Node con Prisma), che richiederebbe una seconda implementazione del motore regole; Firebase o Supabase (gestiti, meno manutenzione ma meno controllo). Con questi volumi di utenti i costi sarebbero comunque trascurabili; la scelta auto-ospitata scambia un po' di lavoro di manutenzione (backup, aggiornamenti, monitoraggio) con pieno controllo e nessun vincolo verso un fornitore.

### Struttura del repository

Un unico monorepo, con package indipendenti:

```
morra_vda/
 ├─ apps/
 │   ├─ mobile/            # app Flutter
 │   └─ server/            # server Serverpod
 ├─ packages/
 │   ├─ morra_rules/       # MOTORE REGOLE (Dart puro, senza dipendenze da Flutter)
 │   │    ├─ scoring/         # conta-partite, abbassamento mano, vittoria partita/incontro
 │   │    ├─ pairing/         # abbinamenti baraonda / coppia fissa, gestione resto
 │   │    └─ ranking/         # punti di tappa e classifica di stagione
 │   └─ morra_client/      # client generato da Serverpod
 └─ docs/
     └─ PROJECT.md
```

Dentro l'app mobile il codice è organizzato a livelli:

```
apps/mobile/lib/
 ├─ presentation/   # schermate e widget
 ├─ application/    # casi d'uso, gestione stato
 └─ data/           # client API generato, SQLite locale, sincronizzazione offline
```

Il **motore regole** è la parte più delicata: viene mantenuto come codice Dart puro, in un package a sé, e coperto da **test automatici**, in modo da poterlo verificare con i casi reali (parità, abbassamenti, resti, spareggi) senza avviare né l'app né il server.

### Sicurezza

- Autorizzazione per ruolo sul server (giocatore / segnapunti / admin); facoltativamente row-level security di PostgreSQL.
- Solo admin e segnapunti abilitati possono scrivere punteggi; il client non è mai considerato affidabile.
- Registro di audit per ogni modifica ai risultati.

---

## App gestionale web e backend condiviso

Oltre all'app mobile, il progetto prevede un'**app gestionale web** (console admin) che usa lo **stesso server e lo stesso database**. Gli organizzatori possono gestire la stagione comodamente da PC, mentre i giocatori continuano a usare l'app mobile.

Il piano attuale è realizzarla in **Flutter Web**, riutilizzando il client generato, il package delle regole e le competenze Dart già necessarie per l'app. Un front end web separato (ad esempio Nuxt) resta possibile in futuro, chiamando endpoint REST esposti dal server; è un punto ancora da definire.

### Perché un'app web

- Più rapida e comoda per **inserimento e gestione dei dati** su schermo grande (calendario, iscritti, pagamenti, ruoli).
- Migliore per le attività di **convalida e moderazione** (classifiche, foto) e per le **esportazioni**.
- Una pagina web è la scelta naturale per la **schermata di proiezione** della classifica live sul televisore del locale (basta aprire un indirizzo).
- Eventuali **pagine pubbliche di sola lettura** (calendario, classifiche, albo d'oro) condivisibili con chiunque, senza app né account.

### Funzionalità web

- **Dashboard admin**: prossima tappa, iscrizioni, check-in, quote incassate.
- **Gestione calendario**: creazione, modifica, annullamento tappe; luogo e indicazioni.
- **Iscritti**: elenchi, registro presenze, stato quota, check-in manuale.
- **Ruoli**: promozione dei giocatori a segnapunti o admin.
- **Controllo del torneo live**: generazione abbinamenti, gestione del resto, partite in corso.
- **Convalida classifica**: verifica del calcolo automatico e pubblicazione come ufficiale.
- **Configurazione del regolamento** per stagione e tappa (punti, target, abbassamento mano, premi).
- **Moderazione foto** e galleria finale di stagione.
- **Esportazioni** (PDF/CSV) e **vista proiezione** per il televisore.
- **Registro di audit** delle modifiche ai risultati.

### Architettura complessiva

```
 App Flutter (iOS / Android)         Gestionale web (Flutter Web, + pagine pubbliche)
        │  SQLite locale (offline)              │
        └──────────────┬────────────────────────┘
                       │  client generato, HTTPS / WebSocket
              Cloudflare Tunnel (TLS, DNS)
                       │
              ┌────────┴─────────┐   Server proprio (SSD Nodes, Docker Compose)
              │ Server Serverpod │   usa morra_rules
              ├──────────────────┤
              │   PostgreSQL     │   file   job programmati (future call)
              └──────────────────┘
                       │
              FCM / APNs (solo consegna push)
```

### Sincronizzazione offline

L'app mobile registra i punteggi come **eventi** con un ID univoco generato dal client, un numero d'ordine per partita e un timestamp. Quando torna la connessione, gli eventi vengono inviati al server, che:

1. li **inserisce in modo idempotente** (nessun duplicato se inviati due volte);
2. **rigioca l'intero registro** della partita con il motore regole condiviso, convalidando ogni evento (parità richiesta per abbassare la mano, una sola volta per squadra, partita già terminata, e così via);
3. salva lo stato risultante come ufficiale e aggiorna le viste live tramite streaming.

Se il replay fallisce, la partita non viene scartata: viene segnalata **"da verificare"** a un admin, perché in un bar senza campo una serata intera di punteggi non deve mai andare persa. Poiché gli eventi sono solo aggiunti e mai modificati, i conflitti sono rari e la partita è sempre ricostruibile.

### Un solo motore regole

Il motore regole è un unico package Dart, `morra_rules`, importato dall'app mobile (conteggio live, anche offline) e dal server Serverpod (convalida, abbinamenti, punti di tappa, classifiche). Non esiste una seconda implementazione da tenere allineata, quindi app e server non possono divergere. Il server resta l'autorità: l'app applica le regole in locale solo per funzionare senza connessione.

### Gestione di un server auto-ospitato

- **Docker Compose**: PostgreSQL, il server Serverpod e `cloudflared`. Database e server non pubblicano porte sull'host; l'unico ingresso è il tunnel, che espone solo la porta pubblica dell'API. La porta di monitoraggio/Insights non viene pubblicata.
- **Migrazioni**: create con gli strumenti di Serverpod e applicate all'avvio del server; mai modificare lo schema a mano.
- **Backup**: dump PostgreSQL programmati, conservati anche **fuori dal server**, con prova di ripristino.
- **Monitoraggio e aggiornamenti**: controllo dell'uptime, log, aggiornamenti regolari di sistema, immagini e dipendenze.
- **Sicurezza**: HTTPS tramite Cloudflare, segreti e file delle password fuori dal repository, rate limiting, **Cloudflare Access** davanti alla console admin.
- **Ambienti**: un ambiente di test separato per provare le modifiche alle regole prima di una tappa reale.
- **Disponibilità**: grazie all'approccio offline-first, un breve disservizio del server non blocca un torneo.

---

## Modello dati (bozza)

Definito come modelli Serverpod, da cui vengono generati tabelle, migrazioni e classi del client.

- **users**: profilo, ruolo, foto, consensi
- **seasons**: stagione, regolamento (`RuleSet`), stato
- **tournaments (tappe)**: data, luogo, modalità (baraonda / coppia fissa), stato (programmata / live / chiusa / convalidata)
- **registrations**: giocatore, tappa, stato prenotazione, check-in, quota pagata
- **matches**: tappa, squadre, giocatori, stato (compreso "da verificare"), risultato finale
- **match_events**: eventi di punteggio (id, partita, numero d'ordine, dispositivo, tipo, payload)
- **standings**: classifica di tappa e di stagione (calcolata, poi convalidata)
- **photos**: autore, tappa, stato di moderazione
- **audit_log**: modifiche ai risultati

---

## Privacy e aspetti legali

- **GDPR**: informativa privacy, consensi espliciti (profilo, foto), diritto di accesso e cancellazione.
- **Minorenni**: se previsti, richiedono il consenso di chi esercita la responsabilità genitoriale.
- **Eliminazione account** direttamente dall'app (richiesto dagli store).
- **Dati auto-ospitati**: da documentare ubicazione del server e dei backup, controllo degli accessi, tempi di conservazione e procedura in caso di violazione dei dati.
- **Sign in with Apple** obbligatorio su iOS se si offrono altri login social.
- **Foto**: consenso alla pubblicazione e procedura di rimozione.
- **Quote di iscrizione**: verificare con l'organizzazione eventuali obblighi fiscali o associativi.
- **Questo repository non contiene dati personali reali**: tutti i dati di esempio, le fixture e gli screenshot sono fittizi, e i dati reali dei giocatori vivono solo nel database di produzione. I segreti non vengono mai committati (si usano segnaposto come `.env.example`).

---

## Roadmap

**Fase 1 – MVP**

- Server Serverpod + PostgreSQL in Docker sul server proprio
- Rafforzamento del package regole: ID evento univoci, numeri d'ordine, replay convalidato
- Registrazione e ruoli
- Calendario tappe
- Prenotazione e check-in QR (con registrazione quota)
- **Conta-partite offline** con sincronizzazione
- Classifica di tappa
- **Gestionale web (base)**: calendario, iscritti, ruoli

**Fase 2 – Torneo live**

- Abbinamenti automatici (baraonda e coppia fissa, gestione resto)
- Modalità live e classifica provvisoria
- Classifica di stagione con convalida admin
- **Gestionale web**: controllo live, convalida, configurazione regolamento
- Notifiche (promemoria e "ne manca uno")

**Fase 3 – Comunità**

- Condividi momenti
- Statistiche, albo d'oro
- Esportazioni PDF/CSV, schermata proiezione (web)
- **Pagine web pubbliche** (calendario, classifiche, albo d'oro), moderazione foto
- Italiano / francese

---

## Idee future

### 1. Versione "light" senza registrazione

Una versione (o modalità) dell'app **utilizzabile senza creare un account**, pensata per chi vuole solo provare il gioco o usare gli strumenti base.

- **Cosa include**: conta-partite (anche per partite amichevoli fuori torneo), regole del gioco, mini-gioco con i bot (vedi sotto), consultazione pubblica di calendario e classifica generale.
- **Cosa non include**: profilo, iscrizione alle tappe, check-in, notifiche personali, statistiche salvate nel cloud, invio foto.
- **Dati**: salvati solo **in locale** sul dispositivo, senza raccolta di dati personali (vantaggio anche per la privacy).
- **Passaggio alla versione completa**: possibilità di registrarsi in un secondo momento, riportando lo storico locale nell'account.
- **Obiettivo**: abbassare la barriera d'ingresso, far conoscere il gioco a nuovi giocatori e turisti, e servire da "vetrina" per la community.

### 2. Mini-gioco della morra contro i bot

Un **gioco simpatico dentro l'app** che simula la morra reale, giocabile **da soli contro dei bot** (e in futuro anche online).

- **Meccanica base**: a ogni mano il giocatore sceglie le dita (1–5) e dichiara la somma (2–10); il bot fa lo stesso in contemporanea. Si applicano le stesse regole del gioco reale, compreso il punto nullo se i due numeri detti coincidono.
- **Formato**: partita a 16 punti, con la possibilità di **abbassare la mano** come nel gioco vero.
- **Bot con personalità**: diversi livelli e stili (prudente, aggressivo, "tende a dire sempre lo stesso numero", ecc.), per dare varietà e un po' di sfida.
- **Modalità a coppie**: 2 contro 2 con compagni bot, per riprodurre il formato da torneo.
- **Online** (fase successiva): sfide tra giocatori reali, magari con classifica dedicata e amichevoli a distanza.
- **Scopo**: allenarsi, imparare le regole in modo divertente, far avvicinare i più giovani al gioco tradizionale e tenere viva l'app anche fuori dalle tappe.
- **Aspetti tecnici**: la simulazione riutilizza lo stesso package `morra_rules` (punteggio, abbassamento, vittoria partita), con in più la logica dei bot.

### 3. Altre idee da valutare

- Modalità **tutorial** interattivo per imparare a giocare.
- **Obiettivi e badge** (anche per il mini-gioco).
- Collegamento tra mini-gioco e profilo, per chi ha l'account (statistiche separate dai tornei reali).

---

## Punti ancora da definire

- **Resto**: criteri esatti di rotazione per chi riceve la vittoria a tavolino e punteggio assegnato.
- **Classifica di stagione**: scarti, criteri di spareggio, eventuali categorie.
- **Quota di 10 €**: eventuale gestione di sconti, omaggi o pagamenti anticipati.
- **Lingue**: italiano e francese, e valutare l'aggiunta del patois.
- **Gestione minorenni** e responsabile del trattamento dei dati.
- **Front end admin**: solo Flutter Web, oppure un'app web separata (es. Nuxt) che chiama endpoint REST; e se offrire pagine pubbliche di sola lettura.
- **Autenticazione e storage dei file**: quali opzioni di auth di Serverpod abilitare (solo email o anche login social) e dove conservare le foto.
- **Regola di annullamento**: solo l'ultimo evento attivo, oppure rivalidazione dell'intera sequenza.
- **Backup e hosting**: dove conservare le copie fuori dal server e chi si occupa della manutenzione.

---

_Documento di progetto._
