<a id="english"></a>

[🇬🇧 English](#english) · [🇮🇹 Italiano](#italiano)

# 🤟 Morra Valdostana – Tournament App

> Mobile app (iOS and Android) to organise, play and follow **Morra Valdostana** tournaments: stage calendar, sign-ups with check-in, live standings, a match score counter and season rankings.

**Project status:** concept / design phase
**Planned technology:** Flutter (Dart)

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
- Results such as **3-0, 3-1, 3-2** (used for stage points) describe the overall outcome of the **match** (_incontro_) between the two teams, won by winning 3 games. _(Term and format to be confirmed, see "Open questions".)_

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

---

## Live tournament and pairings

The admin starts **live mode** for the stage. The app generates pairings in two modes:

### Baraonda

Pairs are drawn at each round, **avoiding as far as possible** repeating the same partners and the same opponents. Points go to **individual players**. Final phases (final, semi-finals, etc.) can also award prizes to teams.

### Fixed pairs (coppia fissa)

Pairs are decided in advance and stay the same for the whole stage. Points go to the **pair**, which is rewarded as such.

### When the number of players is not a multiple of 4

Since the game is played by four, a number of players that is not a multiple of 4 leaves a **remainder**. The admin can choose how to handle it:

1. **Walkover win ("lucky one")**: one or more players are awarded a won game, assigned **in a fair rotation** so it is not always the same person who benefits.
2. **Individual 1-vs-1 play-off** between the players left out.

The method is a configurable setting of the stage.

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

The backend is **self-hosted** (own server on SSD Nodes, exposed through **Cloudflare Tunnel**) and shared by the mobile app and the web admin app.

| Component               | Choice                                                                                                    |
| ----------------------- | --------------------------------------------------------------------------------------------------------- |
| Mobile app              | **Flutter / Dart** (iOS + Android)                                                                        |
| State management        | Riverpod (or Bloc)                                                                                        |
| Web admin app           | **Nuxt** (Vue), see [next section](#web-admin-app-and-shared-backend)                                     |
| Backend / API           | Nuxt server routes (Nitro) or a dedicated service (e.g. Node.js), one API for mobile and web              |
| Database                | **PostgreSQL**, shared by mobile and web                                                                  |
| Local mobile storage    | SQLite (e.g. Drift) for **offline use**, synced with the server                                           |
| Authentication          | Email + password with sessions/tokens; roles stored in the database                                       |
| Real time               | WebSocket or Server-Sent Events (live rankings and results)                                               |
| Files (photos, avatars) | S3-compatible storage (e.g. MinIO) or server disk, always behind the API                                  |
| Push notifications      | Logic on the own server; delivery through FCM (Android) and APNs (iOS), which are required for phone push |
| Scheduled jobs          | Cron / job queue on the server (ranking recalculation, reminders, "one missing" alerts)                   |

_Alternatives worth considering:_ Firebase or Supabase (managed, less maintenance but less control). With these user volumes, costs would be negligible in any case; the self-hosted choice trades some maintenance work (backups, updates, monitoring) for full control and no vendor lock-in.

### Layered structure

```
app/
 ├─ presentation/   # screens and widgets
 ├─ application/    # use cases, state management
 ├─ domain/         # RULES ENGINE (pure Dart, no Flutter dependencies)
 │    ├─ rules/         # configurable RuleSet
 │    ├─ scoring/       # score counter, lowering the hand, game/match victory
 │    ├─ pairing/       # baraonda / fixed-pairs pairings, remainder handling
 │    └─ ranking/       # stage points and season ranking
 └─ data/           # API client, local SQLite, offline sync
```

The **rules engine** is the most delicate part: it is kept as pure Dart code and covered by **automated tests**, so it can be verified against real cases (ties, lowering, remainders, play-offs) without launching the app.

### Security

- Role-based authorisation on the API (player / scorekeeper / admin); optionally PostgreSQL row-level security.
- Only admins and authorised scorekeepers can write scores.
- Audit log for every change to results.

---

## Web admin app and shared backend

Besides the mobile app, the project includes a **web management app** (admin console) that uses the **same database and the same API**. Organisers can run the season comfortably from a PC, while players keep using the mobile app.

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
 Flutter app (iOS / Android)        Nuxt web app (admin + public pages)
        │  local SQLite (offline)               │
        └──────────────┬────────────────────────┘
                       │  HTTPS / WebSocket
              Cloudflare Tunnel (TLS, DNS)
                       │
              ┌────────┴─────────┐   Own server (SSD Nodes)
              │   API / backend  │
              ├──────────────────┤
              │   PostgreSQL     │   files (S3-compatible)   job queue / cron
              └──────────────────┘
                       │
              FCM / APNs (push delivery only)
```

### Offline sync

The mobile app records scores as **events** with a client-generated unique ID. When the connection returns, events are sent to the server, which **inserts them idempotently** (no duplicates if sent twice) and updates the live views through real time. Because events are append-only, conflicts are rare and the game can always be reconstructed.

### One rules engine, or two?

The rules engine is written in Dart for the mobile app (live scoring), while a Nuxt/Node backend runs on TypeScript. To avoid the two implementations drifting apart:

- **the server is the authority** for pairings, stage points and rankings, so the web app and the mobile app always show the same result;
- the mobile app only applies the rules locally for **live score counting**, so it works offline;
- a shared set of **test cases** (JSON files with inputs and expected results) is run against both implementations.

_Alternative:_ write the backend in Dart as well, so a single rules engine is shared. It is a valid option, but less aligned with the usual Nuxt/PostgreSQL stack.

### Operations on a self-hosted server

- **Backups**: scheduled PostgreSQL dumps, stored also **off the server**, with a restore test.
- **Monitoring and updates**: uptime check, logs, regular OS and dependency updates.
- **Security**: HTTPS through Cloudflare, secrets kept out of the repository, rate limiting, minimal exposed ports (Cloudflare Tunnel needs no open inbound ports).
- **Environments**: a separate test environment to try rules changes before a real stage.
- **Availability**: thanks to offline-first, a short server outage does not stop a tournament.

---

## Data model (draft)

- **users**: profile, role, photo, consents
- **seasons**: season, rules (`RuleSet`), status
- **tournaments (stages)**: date, venue, mode (baraonda / fixed pairs), status (scheduled / live / closed / validated)
- **registrations**: player, stage, booking status, check-in, fee paid
- **matches**: stage, teams, players, status, final result
- **match_events**: scoring events (point, lowering, undo)
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

---

## Roadmap

**Phase 1 – MVP**

- Backend (API + PostgreSQL) on the own server
- Registration and roles
- Stage calendar
- Booking and QR check-in (with fee recording)
- **Offline score counter**
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
- **Technical aspects**: the simulation reuses the app's same Dart rules engine (scoring, lowering, game victory), plus the bot logic.

### 3. Other ideas to evaluate

- Interactive **tutorial** mode to learn how to play.
- **Achievements and badges** (also for the mini-game).
- Link between the mini-game and the profile for account holders (statistics separate from real tournaments).

---

## Open questions

- **Match format**: do the 3-0, 3-1, 3-2 results indicate games won (best of 5)? What is the official name of this unit, and how should the deciding game at 21 be configured?
- **Remainder**: exact rotation criteria for who receives the walkover win, and the score awarded.
- **Baraonda finals**: how finalists are selected (top N of the ranking, bracket, etc.) and how teams are rewarded.
- **Season ranking**: dropped results, tie-break criteria, possible categories.
- **€10 fee**: possible handling of discounts, freebies or advance payments.
- **Languages**: Italian and French, and consider adding Patois.
- **Handling of minors** and the data controller.
- **Backend technology**: Nuxt server routes or a dedicated service; choice of authentication and file-storage solutions.
- **Web access**: admins only, or also public read-only pages?
- **Backups and hosting**: where to keep off-server copies and who is responsible for maintenance.

---

_Project presentation document – concept version._

---

---

<a id="italiano"></a>

[🇬🇧 English](#english) · [🇮🇹 Italiano](#italiano)

# 🤟 Morra Valdostana – App per i tornei

> App mobile (iOS e Android) per organizzare, giocare e seguire i tornei di **Morra Valdostana**: calendario delle tappe, iscrizioni con check-in, classifica live, conta-partite e classifica di stagione.

**Stato del progetto:** concept / fase di progettazione
**Tecnologia prevista:** Flutter (Dart)

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

Un incontro è una successione di mani in cui i giocatori accumulano punti fino al **punteggio target** (di norma 16). Nel torneo questo duello si inserisce nel formato a coppie descritto qui sotto.

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
- I risultati del tipo **3-0, 3-1, 3-2** (usati per i punti di tappa) descrivono l'esito complessivo dell'**incontro** tra le due squadre, che si vince arrivando a 3 partite. _(Termine e formato da confermare, vedi "Punti ancora da definire".)_

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

---

## Torneo live e abbinamenti

L'admin avvia la **modalità live** per la tappa. L'app genera gli abbinamenti in due modalità:

### Baraonda

Le coppie si formano a sorteggio a ogni turno, **evitando per quanto possibile** di ripetere gli stessi compagni e gli stessi avversari. I punti vanno ai **singoli giocatori**. Le fasi finali (finale, semifinali, ecc.) possono assegnare premi anche alle squadre.

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

| Risultato partita | Punti a ciascun componente della squadra vincente | Perdenti    |
| ----------------- | ------------------------------------------------- | ----------- |
| 3-0               | **3 punti**                                       | 0           |
| 3-1               | **3 punti**                                       | 0           |
| 3-2               | **2 punti**                                       | **1 punto** |

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

Il backend è **auto-ospitato** (server proprio su SSD Nodes, esposto tramite **Cloudflare Tunnel**) e condiviso tra l'app mobile e l'app gestionale web.

| Componente             | Scelta                                                                                                    |
| ---------------------- | --------------------------------------------------------------------------------------------------------- |
| App mobile             | **Flutter / Dart** (iOS + Android)                                                                        |
| Gestione stato         | Riverpod (o Bloc)                                                                                         |
| App gestionale web     | **Nuxt** (Vue), vedi [sezione successiva](#app-gestionale-web-e-backend-condiviso)                        |
| Backend / API          | Route server di Nuxt (Nitro) o servizio dedicato (es. Node.js), un'unica API per mobile e web             |
| Database               | **PostgreSQL**, condiviso da mobile e web                                                                 |
| Archivio locale mobile | SQLite (es. Drift) per l'**uso offline**, sincronizzato con il server                                     |
| Autenticazione         | Email + password con sessioni/token; ruoli salvati nel database                                           |
| Tempo reale            | WebSocket o Server-Sent Events (classifiche e risultati live)                                             |
| File (foto, avatar)    | Storage compatibile S3 (es. MinIO) o disco del server, sempre dietro l'API                                |
| Notifiche push         | Logica sul server proprio; consegna tramite FCM (Android) e APNs (iOS), necessari per le push su telefono |
| Job programmati        | Cron / coda di job sul server (ricalcolo classifiche, promemoria, avvisi "ne manca uno")                  |

_Alternative valutabili:_ Firebase o Supabase (gestiti, meno manutenzione ma meno controllo). Con questi volumi di utenti i costi sarebbero comunque trascurabili; la scelta auto-ospitata scambia un po' di lavoro di manutenzione (backup, aggiornamenti, monitoraggio) con pieno controllo e nessun vincolo verso un fornitore.

### Struttura a livelli

```
app/
 ├─ presentation/   # schermate e widget
 ├─ application/    # casi d'uso, gestione stato
 ├─ domain/         # MOTORE REGOLE (Dart puro, senza dipendenze da Flutter)
 │    ├─ rules/         # RuleSet configurabile
 │    ├─ scoring/       # conta-partite, abbassamento mano, vittoria partita/incontro
 │    ├─ pairing/       # abbinamenti baraonda / coppia fissa, gestione resto
 │    └─ ranking/       # punti di tappa e classifica di stagione
 └─ data/           # client API, SQLite locale, sincronizzazione offline
```

Il **motore regole** è la parte più delicata: viene mantenuto come codice Dart puro e coperto da **test automatici**, in modo da poterlo verificare con i casi reali (parità, abbassamenti, resti, spareggi) senza avviare l'app.

### Sicurezza

- Autorizzazione per ruolo sull'API (giocatore / segnapunti / admin); facoltativamente row-level security di PostgreSQL.
- Solo admin e segnapunti abilitati possono scrivere punteggi.
- Registro di audit per ogni modifica ai risultati.

---

## App gestionale web e backend condiviso

Oltre all'app mobile, il progetto prevede un'**app gestionale web** (console admin) che usa lo **stesso database e la stessa API**. Gli organizzatori possono gestire la stagione comodamente da PC, mentre i giocatori continuano a usare l'app mobile.

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
 App Flutter (iOS / Android)         App web Nuxt (admin + pagine pubbliche)
        │  SQLite locale (offline)              │
        └──────────────┬────────────────────────┘
                       │  HTTPS / WebSocket
              Cloudflare Tunnel (TLS, DNS)
                       │
              ┌────────┴─────────┐   Server proprio (SSD Nodes)
              │   API / backend  │
              ├──────────────────┤
              │   PostgreSQL     │   file (compatibile S3)   coda job / cron
              └──────────────────┘
                       │
              FCM / APNs (solo consegna push)
```

### Sincronizzazione offline

L'app mobile registra i punteggi come **eventi** con un ID univoco generato dal client. Quando torna la connessione, gli eventi vengono inviati al server, che li **inserisce in modo idempotente** (nessun duplicato se inviati due volte) e aggiorna le viste live in tempo reale. Poiché gli eventi sono solo aggiunti e mai modificati, i conflitti sono rari e la partita è sempre ricostruibile.

### Un motore regole o due?

Il motore regole è scritto in Dart per l'app mobile (conteggio live), mentre un backend Nuxt/Node usa TypeScript. Per evitare che le due implementazioni divergano:

- **il server è l'autorità** per abbinamenti, punti di tappa e classifiche, così web e mobile mostrano sempre lo stesso risultato;
- l'app mobile applica le regole in locale solo per il **conteggio live dei punti**, così funziona offline;
- un insieme condiviso di **casi di test** (file JSON con input e risultati attesi) viene eseguito su entrambe le implementazioni.

_Alternativa:_ scrivere anche il backend in Dart, condividendo un solo motore regole. È un'opzione valida, ma meno in linea con il solito stack Nuxt/PostgreSQL.

### Gestione di un server auto-ospitato

- **Backup**: dump PostgreSQL programmati, conservati anche **fuori dal server**, con prova di ripristino.
- **Monitoraggio e aggiornamenti**: controllo dell'uptime, log, aggiornamenti regolari di sistema e dipendenze.
- **Sicurezza**: HTTPS tramite Cloudflare, segreti fuori dal repository, rate limiting, porte esposte ridotte al minimo (Cloudflare Tunnel non richiede porte in ingresso aperte).
- **Ambienti**: un ambiente di test separato per provare le modifiche alle regole prima di una tappa reale.
- **Disponibilità**: grazie all'approccio offline-first, un breve disservizio del server non blocca un torneo.

---

## Modello dati (bozza)

- **users**: profilo, ruolo, foto, consensi
- **seasons**: stagione, regolamento (`RuleSet`), stato
- **tournaments (tappe)**: data, luogo, modalità (baraonda / coppia fissa), stato (programmata / live / chiusa / convalidata)
- **registrations**: giocatore, tappa, stato prenotazione, check-in, quota pagata
- **matches**: tappa, squadre, giocatori, stato, risultato finale
- **match_events**: eventi di punteggio (punto, abbassamento, annulla)
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

---

## Roadmap

**Fase 1 – MVP**

- Backend (API + PostgreSQL) sul server proprio
- Registrazione e ruoli
- Calendario tappe
- Prenotazione e check-in QR (con registrazione quota)
- **Conta-partite offline**
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
- **Aspetti tecnici**: la simulazione riutilizza lo stesso motore regole Dart dell'app (punteggio, abbassamento, vittoria partita), con in più la logica dei bot.

### 3. Altre idee da valutare

- Modalità **tutorial** interattivo per imparare a giocare.
- **Obiettivi e badge** (anche per il mini-gioco).
- Collegamento tra mini-gioco e profilo, per chi ha l'account (statistiche separate dai tornei reali).

---

## Punti ancora da definire

- **Formato dell'incontro**: i risultati 3-0, 3-1, 3-2 indicano partite vinte (al meglio delle 5)? Come si chiama ufficialmente questa unità e come configurare la "bella" a 21?
- **Resto**: criteri esatti di rotazione per chi riceve la vittoria a tavolino e punteggio assegnato.
- **Finali in baraonda**: come si selezionano i finalisti (primi N della classifica, tabellone, ecc.) e come si premiano le squadre.
- **Classifica di stagione**: scarti, criteri di spareggio, eventuali categorie.
- **Quota di 10 €**: eventuale gestione di sconti, omaggi o pagamenti anticipati.
- **Lingue**: italiano e francese, e valutare l'aggiunta del patois.
- **Gestione minorenni** e responsabile del trattamento dei dati.
- **Tecnologia backend**: route server di Nuxt o servizio dedicato; scelta di autenticazione e storage dei file.
- **Accesso web**: solo admin, oppure anche pagine pubbliche di sola lettura?
- **Backup e hosting**: dove conservare le copie fuori dal server e chi si occupa della manutenzione.

---

_Documento di presentazione del progetto – versione di concept._
