# RallyQ

RallyQ is a badminton open-play platform designed to make doubles sessions fairer and easier to run. Hosts create sessions and configure courts, players join individually, temporary pairs enter a strict FIFO queue, and the system coordinates match calls, scores, history, and ratings.

The project is currently backend-first. Authentication and the Phase 1 database model are implemented; session creation is the next development milestone.

## Phase 1 product rules

- Phase 1 supports doubles only.
- Players join sessions individually but cannot enter the match queue alone.
- Both players must accept a temporary partnership.
- Accepting a partnership automatically adds the pair to the queue.
- Queue priority is FIFO by pair; ratings cannot allow newer pairs to skip older pairs.
- Queue time begins when the partnership is formed.
- Partnerships dissolve after one match, returning all four players to the partner lobby individually.
- Partner-lobby visits record when players enter, leave, and how long they remain visible.
- When one called pair declines, the willing pair remains called while the next eligible pair is offered the match.
- Match calls track confirmations, declines, timeouts, replacements, and other state changes.
- Players start the match timer after both sides confirm.
- Any match participant may submit a score, but an opponent must verify it.
- Score disputes are resolved by a host.
- A court becomes available when play ends, even if score verification is still pending.
- Current ratings and immutable rating-change history are stored separately.

## Current implementation

### Complete

- PostgreSQL development database configuration
- Prisma 7 schema and migrations for the full Phase 1 domain
- Shared Prisma Client using `@prisma/adapter-pg`
- Express 5 and TypeScript server
- API and database health endpoints
- Player registration with Zod validation
- bcrypt password hashing with cost factor 12
- Automatic initial player rating creation
- Player login with generic invalid-credential responses
- JWT authentication stored in an HTTP-only cookie
- Protected current-player endpoint
- Logout through cookie expiration
- Centralized, validated environment configuration
- Consistent unknown-route and unexpected-error middleware

### Next

- Protected session creation
- Owner host assignment
- Court creation within the session transaction
- Server-generated join codes

### Planned

1. Session creation, hosts, participants, and courts
2. QR-code joining and partner-lobby visits
3. Partnership requests, temporary partnerships, and automatic queue entry
4. FIFO match calls, confirmations, declines, and court transitions
5. Match timing, score submission, verification, disputes, and history
6. Rating calculations and rating history
7. Partner suggestions and host-proposed pairs
8. React and Vite client

## Technology

- TypeScript
- Node.js
- Express 5
- PostgreSQL
- Prisma 7 with `@prisma/adapter-pg`
- Zod
- bcrypt
- JSON Web Tokens
- Docker for local PostgreSQL
- React and Vite planned for the client

## Repository structure

```text
rally_q/
├── README.md
└── server/
    ├── prisma/
    │   ├── migrations/
    │   └── schema.prisma
    ├── src/
    │   ├── config/
    │   ├── controllers/
    │   ├── generated/prisma/    # generated and ignored
    │   ├── middleware/
    │   ├── routes/
    │   ├── schemas/
    │   ├── services/
    │   ├── types/
    │   ├── utils/
    │   ├── app.ts
    │   └── server.ts
    ├── .env.example
    ├── package.json
    ├── prisma.config.ts
    └── tsconfig.json
```

## Local development

### Requirements

- A current Node.js release
- npm
- Docker Desktop or another PostgreSQL instance

The local Docker database is expected on port `5433` because macOS PostgreSQL may already use `5432`.

### Environment

From `server/`, copy the example file:

```bash
cp .env.example .env
```

Configure these values:

```dotenv
DATABASE_URL=postgresql://postgres:postgres@localhost:5433/badminton_open_play?schema=public
PORT=5000
NODE_ENV=development
JWT_SECRET=replace_with_a_long_random_secret
AUTH_SESSION_DAYS=7
```

Never commit `.env`. The tracked `.env.example` contains placeholders only.

### Install and prepare Prisma

```bash
cd server
npm install
npm run db:validate
npm run db:migrate
npm run db:generate
```

### Start the API

```bash
npm run dev
```

The API runs at `http://localhost:5000` by default.

### Useful commands

```bash
npm run dev          # start the development server with watch mode
npm run build        # compile TypeScript
npm run start        # run the compiled server
npm run db:format    # format the Prisma schema
npm run db:validate  # validate Prisma configuration and schema
npm run db:migrate   # create or apply a development migration
npm run db:generate  # regenerate Prisma Client
npm run db:studio    # inspect local data in Prisma Studio
```

## API endpoints

| Method | Endpoint | Authentication | Purpose |
| --- | --- | --- | --- |
| `GET` | `/api/health` | No | Confirm that the API is running |
| `GET` | `/api/health/database` | No | Confirm that Prisma can query PostgreSQL |
| `POST` | `/api/players/register` | No | Register a player and set the auth cookie |
| `POST` | `/api/players/login` | No | Authenticate a player and set the auth cookie |
| `GET` | `/api/players/me` | Yes | Return the authenticated player's safe profile and rating |
| `POST` | `/api/players/logout` | No | Expire the auth cookie, including stale or invalid cookies |

Unknown routes return a consistent JSON `404` response.

## Authentication examples

The JWT is stored in the `rallyq_token` HTTP-only cookie and is not returned in JSON.

Register and save the cookie:

```bash
curl -i -c cookies.txt \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Test",
    "lastName": "Player",
    "email": "test@example.com",
    "password": "replace-with-a-test-password",
    "skillLevel": "INTERMEDIATE"
  }' \
  http://localhost:5000/api/players/register
```

Retrieve the authenticated player:

```bash
curl -i -b cookies.txt http://localhost:5000/api/players/me
```

Log out and update the cookie jar:

```bash
curl -i -b cookies.txt -c cookies.txt \
  -X POST http://localhost:5000/api/players/logout
```

## Application-level invariants

The relational schema enforces IDs, foreign keys, uniqueness, and indexes. The service layer must enforce rules that ordinary database constraints cannot fully express:

1. A partnership contains exactly two distinct participants from the same session.
2. A participant belongs to only one active partnership at a time.
3. Both participants must be in `PARTNER_LOBBY` before accepting a partnership.
4. Partnership acceptance creates the partnership, two members, and queue entry in one transaction.
5. A match contains exactly two sides and four distinct players from the same session.
6. A match side can be confirmed only by one of its two players.
7. A score can be verified only by a player on the opposing side.
8. Ratings change only after a verified or host-resolved score.
9. Queue ordering uses `originalPriorityAt`; declined pairs must be temporarily excluded to prevent call loops.
10. Ending a match releases its court immediately, even while score verification is pending.
11. Ending a match dissolves both partnerships and creates new partner-lobby visits for all four players.

Multi-record operations should use Prisma transactions.

## Deferred features

- Singles
- Permanent teams
- Structured side and play-style preferences
- Advanced matchmaking and machine learning
- Video analysis
- Leagues and tournaments
- Payments
- External notifications and chat
