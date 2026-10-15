# F5 -- Booking Request

## Description

A player selects one or more consecutive slots (up to 2 hours) on a single court, reviews the estimated total, and submits the booking as `PENDING`. The system calculates and stores the price at request time (R8). Double-booking is prevented at the database level using a PostgreSQL exclusion constraint or equivalent check. Bookings are limited to 14 days in advance (R2).

## User Stories

- **US-5.1** As a player, I want to select consecutive available slots on a court so that I can book a session.
- **US-5.2** As a player, I want to see the estimated total before submitting so that I know the cost.
- **US-5.3** As a player, I want my booking saved as Pending so that the owner can review it.
- **US-5.4** As a player, I want the system to prevent double bookings so that two people cannot book the same slot.

## Acceptance Criteria

### Slot Selection

- Given a player selects slots, when the slots are not consecutive or span more than 2 hours, then a `400 Bad Request` is returned (R2).
- Given a player selects slots, when any slot is already held by a `PENDING` or `APPROVED` booking, then a `409 Conflict` is returned.
- Given a player selects slots, when any slot is blocked, then a `409 Conflict` is returned.
- Given a player selects slots more than 14 days in the future, then a `400 Bad Request` is returned (R2).
- Given a player selects slots in the past, then a `400 Bad Request` is returned (R1).

### Price Calculation

- Price is calculated as: `court.hourlyPrice * (duration in hours)`.
- For a 30-minute slot: `court.hourlyPrice * 0.5`.
- The calculated `totalPrice` is stored in cents on the booking record at creation time (R8).
- The price is locked at request time and does not change if the court's hourly rate is later updated.

### Booking Creation

- Given all validations pass, when the player submits, then a booking is created with status `PENDING` and a `201` response is returned.
- The booking holds the slot immediately upon creation (other players see those slots as unavailable).

### Double-Booking Prevention

- A database-level constraint (PostgreSQL exclusion constraint or a check within a serializable transaction) prevents two bookings from overlapping on the same court with status `PENDING` or `APPROVED`.
- If a race condition occurs (two requests for the same slot at the same time), one succeeds and the other receives `409 Conflict`.

## API Endpoints

| Method | Path | Auth | Description |
|---|---|---|---|
| `POST` | `/api/bookings` | Player | Create a booking request |

### Request / Response Shapes

**POST /api/bookings**
```json
{
  "courtId": "uuid",
  "date": "2026-03-20",
  "startTime": "2026-03-20T14:00:00Z",
  "endTime": "2026-03-20T16:00:00Z"
}
```
Response `201`:
```json
{
  "id": "uuid",
  "courtId": "uuid",
  "playerId": "uuid",
  "date": "2026-03-20",
  "startTime": "2026-03-20T14:00:00Z",
  "endTime": "2026-03-20T16:00:00Z",
  "totalPrice": 5000,
  "status": "PENDING",
  "createdAt": "2026-03-06T10:30:00Z"
}
```

## Data Model References

- `Booking`: id, courtId, playerId, date, startTime (UTC), endTime (UTC), totalPrice (cents), status, rejectReason, createdAt, updatedAt
- `Court.hourlyPrice` used for price calculation.
- Indexes: `courtId + date`, `playerId`, `status`.

## Edge Cases

- Player attempts to book on a court belonging to an unpublished facility: `404 Not Found` (R7).
- Player with role `OWNER` attempts to book: `403 Forbidden` (only `PLAYER` role can create bookings).
- Booking exactly 14 days from now at end of day: allowed. Booking 15 days from now: rejected.
- Duration of exactly 2 hours: allowed. Duration of 2 hours and 30 minutes: rejected.
- The court's schedule does not cover the requested time: `400 Bad Request`.
- If the booking spans midnight (unlikely for pickleball), the `date` field refers to the start date.

## Out of Scope

- Recurring / repeat bookings.
- Waitlists for fully booked slots.
- Booking modification (change time); player must cancel and rebook.
- Payment capture or hold at booking time.
- Booking confirmation emails or push notifications.
