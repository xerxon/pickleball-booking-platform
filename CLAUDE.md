# Pickleball Booking Platform

A web app where players find pickleball courts and request bookings, and court owners manage their facilities and approve requests.

## Tech Stack

- **Frontend**: Vite + React 19 + TypeScript (`apps/web`)
- **Backend**: Express + TypeScript (`apps/api`)
- **Database**: PostgreSQL with Prisma ORM
- **Monorepo**: pnpm workspaces

## Commands

```bash
# Development
pnpm dev              # Start both frontend and backend
pnpm dev:web          # Start Vite dev server (http://localhost:5173)
pnpm dev:api          # Start Express server (http://localhost:3000)

# Build & Lint
pnpm build            # Build both apps
pnpm typecheck        # Type-check both apps
pnpm lint             # Lint both apps

# Database (from project root)
pnpm --filter @pbp/api db:migrate   # Run Prisma migrations
pnpm --filter @pbp/api db:push      # Push schema without migration
pnpm --filter @pbp/api db:studio    # Open Prisma Studio
pnpm --filter @pbp/api db:seed      # Seed sample data
```

## Architecture

### Frontend (`apps/web`)
- Vite + React with TypeScript
- React Router for client-side routing
- Tailwind CSS v4 for styling
- Proxies `/api` requests to backend in dev

### Backend (`apps/api`)
- Express with TypeScript, run via tsx
- Prisma ORM with PostgreSQL
- JWT authentication
- Role-based access: Player and Owner
- All times stored in UTC, displayed in facility timezone

### Data Model
Core entities: User, Facility, Court, Schedule, BlockedSlot, Booking
Double-booking prevented by PostgreSQL exclusion constraint (`tstzrange`).
Booking lifecycle: Pending → Approved | Rejected | Cancelled | Expired

### Key Business Rules
- Every owner endpoint checks both role AND ownership
- Unpublished facilities are hidden from players
- Bookings up to 2 consecutive hours, up to 14 days ahead
- Price calculated and stored at booking time
- No payment processing — informational only

## Project Structure

```
├── apps/
│   ├── web/                  Frontend (Vite + React)
│   └── api/                  Backend (Express + Prisma)
├── docs/
│   ├── specs/                Product and feature specs
│   │   ├── product.md
│   │   ├── features/         F1-F7 feature specs
│   │   ├── api.md            REST API specification
│   │   └── data-model.md     Database schema docs
│   ├── plans/                Implementation plans per feature
│   ├── rules/                Coding, testing, logging, security rules
│   └── session-logs/         Auto-generated AI session logs
├── .claude/
│   ├── agents/               Agent definitions
│   ├── skills/               Skill definitions
│   └── hooks/                Session logging hooks
└── .github/workflows/        CI pipeline
```

## Specs and Rules
- Product spec: `docs/specs/product.md`
- Feature specs: `docs/specs/features/`
- API spec: `docs/specs/api.md`
- Data model: `docs/specs/data-model.md`
- Rules: `docs/rules/` (coding, testing, logging, security, review)
