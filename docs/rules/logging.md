# Logging Rules

## Format

- **Structured JSON logs**: one JSON object per line.
- Every log entry includes these standard fields:
  - `timestamp` — UTC, ISO 8601 format (e.g., `2026-01-15T09:30:00.000Z`)
  - `level` — one of `ERROR`, `WARN`, `INFO`, `DEBUG`
  - `message` — human-readable description of the event
  - `service` — service name (e.g., `api`)
  - `requestId` — unique ID for the HTTP request (from middleware)

## Log Levels

| Level   | Use for                                          |
|---------|--------------------------------------------------|
| `ERROR` | Failures that need attention — unhandled errors, failed operations |
| `WARN`  | Unexpected but handled situations — fallbacks triggered, retries |
| `INFO`  | Business events — sign-ins, bookings created, owner decisions |
| `DEBUG` | Detailed info for local development only          |

- The active log level is set by the `LOG_LEVEL` environment variable, not hardcoded.
- Production runs at `INFO` or above. `DEBUG` is for local development only.

## What to Log

Log **events**, not noise:

- User sign-in and failed sign-in attempts
- Record changes (create, update, delete) on core entities
- Owner decisions (approve, reject bookings)
- Third-party API calls (request sent, response received, errors)
- Application startup and shutdown

## What Not to Log

- **No sensitive data**: never log passwords, tokens, API keys, or full credit card numbers.
- **Mask emails**: show only the first character and domain (e.g., `j***@example.com`).
- **No leftover `console.log`** or `console.debug` — always use the structured logger.

## Error Logging

When logging errors, include context:

```json
{
  "timestamp": "2026-01-15T09:30:00.000Z",
  "level": "ERROR",
  "message": "Failed to create booking",
  "service": "api",
  "requestId": "req-abc-123",
  "error": {
    "type": "ConflictError",
    "message": "Time slot is already booked",
    "stack": "ConflictError: Time slot is already booked\n    at ...",
    "action": "createBooking"
  }
}
```

Always include: error type, error message, stack trace, requestId, and the action that was attempted.

## Audit Trail (Week 4)

Maintain a separate audit log for booking decisions:

- **Who**: user ID and role
- **What**: action taken (e.g., `booking.approved`, `booking.rejected`)
- **When**: UTC timestamp
- **Why**: reason or context (e.g., owner note, system rule)

The audit trail is stored separately from application logs and must not be mixed with general logging output.
