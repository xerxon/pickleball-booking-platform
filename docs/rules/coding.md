# Coding Conventions

## TypeScript

- **Strict mode** enabled in all `tsconfig.json` files.
- **ESM only** — use `import`/`export`, never `require`/`module.exports`.
- **No `any` type** — use `unknown` or define proper types. If a type is truly unknowable, use `unknown` and narrow with type guards.
- **Named exports preferred** — avoid default exports except where required by framework conventions.
- **`import type` for type-only imports** — `verbatimModuleSyntax` is enabled, so type imports must use `import type { Foo }` or `import { type Foo }`.

## Naming

| Element             | Convention       | Example                    |
|---------------------|------------------|----------------------------|
| Variables/functions | camelCase        | `bookingCount`, `getSlots` |
| Types/interfaces    | PascalCase       | `BookingStatus`, `User`    |
| Classes             | PascalCase       | `AuthService`              |
| Constants           | UPPER_SNAKE_CASE | `MAX_BOOKING_HOURS`        |
| Files               | kebab-case       | `booking-service.ts`       |

## Error Handling

- Throw typed errors (e.g., `AppError` with a status code and error code).
- Use `try/catch` at the **controller level** — services throw, controllers catch.
- Never swallow errors silently. Always log or re-throw.
- Return consistent error response shapes: `{ error: { code, message } }`.

## Express Patterns

- **Auth middleware** runs before route handlers to verify JWT and attach `req.user`.
- **Ownership middleware** verifies the authenticated user owns the resource being accessed.
- Middleware order: auth -> ownership -> validation -> handler.
- Route handlers stay thin — delegate to service functions.

## Database (Prisma)

- Use **Prisma transactions** (`prisma.$transaction`) for multi-step operations that must be atomic.
- Never use raw SQL without parameterization. Prefer Prisma's query builder.
- Keep Prisma schema as the single source of truth for the data model.

## Environment Variables

- Load via `dotenv` at app startup.
- **Never hardcode secrets** (API keys, database URLs, JWT secrets) in source code.
- Access through a typed config module, not scattered `process.env` reads.
- Validate required env vars at startup and fail fast if missing.
