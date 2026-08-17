# AI Badminton Open Play — Database Starter

This starter contains the PostgreSQL/Prisma data model for the Phase 1 open-play application.

## Product rules represented

- A host creates an open-play session and configures its courts.
- Players join a session through a unique join code used by a QR-code URL.
- Doubles only: players must form a mutually accepted temporary partnership before entering the queue.
- Pair queue priority is FIFO using `originalPriorityAt`; rating does not allow newer pairs to skip older pairs.
- Lobby visits track how long each player has been looking for a partner.
- A partnership dissolves after its match, returning each player to the partner lobby individually.
- Match calls support acceptance, declines, timeouts, replacements, and an audit trail.
- Match timing begins only when play starts.
- One player submits game scores and an opponent verifies them; disputes go to a host.
- Current player rating and immutable rating-change history are stored separately.

## Included files

- `prisma/schema.prisma` — complete Phase 1 schema
- `prisma.config.ts` — Prisma CLI configuration
- `.env.example` — local PostgreSQL connection example
- `package.json` — database scripts and required packages

## Local setup

Requirements: a current Node.js release and a running PostgreSQL database.

```bash
npm install
cp .env.example .env
npm run db:format
npm run db:validate
npm run db:migrate -- --name init
npm run db:generate
```

Then inspect the database with:

```bash
npm run db:studio
```

## Important application-level rules

The relational schema enforces IDs, foreign keys, uniqueness, and indexes. The API must enforce rules that ordinary constraints cannot fully express:

1. A partnership contains exactly two distinct participants from the same session.
2. A participant can belong to only one active partnership at a time.
3. Both participants must be in `PARTNER_LOBBY` before a partnership is accepted.
4. Accepting a partnership request must create the partnership, its two members, and its queue entry in one database transaction.
5. A match contains exactly two sides and four distinct players from the same session.
6. A side can be confirmed only by one of its two players.
7. A score can be verified only by a player on the opposing side.
8. Ratings change only after a verified or host-resolved score.
9. Queue ordering uses `originalPriorityAt`; a decline must temporarily exclude that pair from the same call to prevent a loop.
10. Ending a match releases its court immediately, even while score verification is pending.
11. When a match ends, both partnerships dissolve and all four players receive new partner-lobby visits.

Actions that modify several related records should use Prisma transactions.

## Recommended implementation order

1. Player registration, authentication, and rating creation
2. Session creation, hosts, participants, and courts
3. QR-code joining and partner-lobby visits
4. Partnership requests, partnerships, and automatic queue entry
5. FIFO match calls, confirmations, declines, and court transitions
6. Match timer, score submission, verification, and match history
7. Rating calculation and rating history
8. Partner suggestions and host-proposed pairs

## Deferred features

- Preferred side and structured play-style enums
- Singles, permanent teams, leagues, tournaments, and payments
- Advanced machine learning and video analysis
- External notifications and chat

`playStyle` is currently nullable text so it does not block Phase 1. Replace it with structured fields or enums after the product choices are finalized.
