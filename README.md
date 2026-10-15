# Pickleball Booking Platform

A web app where players find pickleball courts and request bookings, and court owners manage their facilities and approve requests.

## Tech Stack

- **Frontend**: Vite + React + TypeScript
- **Backend**: Express + TypeScript
- **Database**: PostgreSQL with Prisma ORM
- **Monorepo**: pnpm workspaces

## Getting Started

### Prerequisites

- Node.js >= 20
- pnpm >= 12
- PostgreSQL 16

### Setup

```bash
# Clone the repo
git clone https://github.com/xerxon/pickleball-booking-platform.git
cd pickleball-booking-platform

# Install dependencies
pnpm install

# Set up the database
cp apps/api/.env.example apps/api/.env
# Edit apps/api/.env with your database URL
pnpm --filter @pbp/api db:migrate

# Start development
pnpm dev
```

The frontend runs at http://localhost:5173 and the API at http://localhost:3000.

## Commands

```bash
pnpm dev          # Start both frontend and backend
pnpm dev:web      # Start frontend only
pnpm dev:api      # Start backend only
pnpm build        # Build both apps
pnpm typecheck    # Type-check both apps
pnpm lint         # Lint both apps
```

## Project Structure

```
├── apps/
│   ├── web/        Frontend (Vite + React)
│   └── api/        Backend (Express + Prisma)
├── docs/
│   ├── specs/      Product and feature specifications
│   ├── plans/      Implementation plans
│   ├── rules/      Coding, testing, logging, security rules
│   └── session-logs/
└── .github/
    └── workflows/  CI pipeline
```

## Documentation

- [Product Spec](docs/specs/product.md)
- [API Spec](docs/specs/api.md)
- [Data Model](docs/specs/data-model.md)
- [Feature Specs](docs/specs/features/)
