# Security Rules

## Input Validation

- Validate **every endpoint** with [zod](https://zod.dev/) schemas.
- Validate request body, query parameters, and path parameters.
- Reject requests that fail validation with a 400 response before any business logic runs.

## SQL Injection Prevention

- Use **Prisma's query builder** for all database access.
- Never use raw SQL (`prisma.$queryRaw`) without parameterized queries (`Prisma.sql` template tag).
- Never concatenate user input into query strings.

## CORS

- Configure CORS for **known origins only** — no wildcard (`*`) in production.
- Allowed origins are set via environment variables.

## Authentication

- **JWT** with an expiry (e.g., 24 hours).
- Tokens sent in the `Authorization: Bearer <token>` header, not cookies (for the API).
- Tokens are validated on every protected request via auth middleware.
- Expired or malformed tokens return 401.

## Password Security

- Hash passwords with **bcrypt**, minimum **10 salt rounds**.
- Never store plaintext passwords.
- Never log passwords, even in debug mode.

## Authorization

- **Role-based route guards**: middleware checks `user.role` before allowing access.
  - `Player` role: can browse facilities, create/cancel bookings.
  - `Owner` role: can manage own facilities, courts, schedules, and booking decisions.
- **Ownership checks**: every owner endpoint verifies the authenticated user **owns** the resource. Role alone is not sufficient — an owner must not access another owner's resources.

## Rate Limiting

- Apply rate limiting on **auth endpoints** (login, register) to prevent brute-force attacks.
- Return 429 Too Many Requests when the limit is exceeded.

## Secrets Management

- No secrets in source code, log output, or frontend bundles.
- Secrets are loaded from environment variables.
- Frontend code never contains API keys, database URLs, or JWT secrets.

## Media

- Photo/image URLs must use **HTTPS** — reject `http://` URLs.

## Webhooks (Week 3)

- Verify **webhook signatures** before processing incoming webhook payloads.
- Reject requests with missing or invalid signatures.

## Transport

- **HTTPS required in production** — enforce via reverse proxy or platform configuration.
- Set security headers (e.g., `Strict-Transport-Security`, `X-Content-Type-Options`).
