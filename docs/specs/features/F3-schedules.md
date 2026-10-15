# F3 -- Schedules and Blocked Slots

## Description

Owners define weekly opening hours for each court and can block individual slots on specific dates. The schedule determines which time slots are generated for a given day. Blocked slots override the schedule and mark a period as unavailable. A slot that is held by a `PENDING` or `APPROVED` booking cannot be blocked (R4).

## User Stories

- **US-3.1** As an owner, I want to set opening hours per weekday for each court so that players know when the court is available.
- **US-3.2** As an owner, I want to choose 30-minute or 60-minute slot lengths so that I can control booking granularity.
- **US-3.3** As an owner, I want to block a slot on a specific date with an optional reason so that I can mark maintenance or closures.
- **US-3.4** As an owner, I want to remove a blocked slot so that the court becomes available again.
- **US-3.5** As a player, I want to see generated time slots for a court on a given date so that I can pick an available window.

## Acceptance Criteria

### Schedule Management

- Given an owner of a court, when they create a schedule for a day of week, then opening hours and slot length are saved.
- Each court has at most one schedule entry per day of week (unique constraint on `courtId + dayOfWeek`).
- `dayOfWeek` is 0 (Sunday) through 6 (Saturday).
- `startTime` and `endTime` are local facility time in `HH:mm` format.
- `slotLength` is either 30 or 60 minutes.
- Given a schedule exists for Monday 08:00-17:00 with 60-min slots, when a player views Monday's availability, then 9 one-hour slots are generated (08:00, 09:00, ... 16:00).

### Blocked Slots

- Given an owner of a court, when they block a slot that has no `PENDING` or `APPROVED` booking, then the blocked slot is created.
- Given an owner attempts to block a slot that overlaps a `PENDING` or `APPROVED` booking, then a `409 Conflict` is returned (R4).
- Blocked slot times are stored in UTC.
- A reason is optional and free-text.
- Given an owner removes a blocked slot, then the underlying schedule slot becomes available again.

### Slot Generation (read-only)

- Given a court with a schedule for the requested day of week, when a player or owner requests availability for a date, then the API returns a list of time slots with their status: `available`, `booked`, or `blocked`.
- Slots in the past are marked as unavailable.
- Slots are returned in the facility's local timezone for display (R3).

## API Endpoints

| Method | Path | Auth | Description |
|---|---|---|---|
| `POST` | `/api/courts/:courtId/schedules` | Owner + ownership | Create or replace schedule for a day |
| `GET` | `/api/courts/:courtId/schedules` | Any | List all schedule entries for a court |
| `PUT` | `/api/courts/:courtId/schedules/:scheduleId` | Owner + ownership | Update a schedule entry |
| `DELETE` | `/api/courts/:courtId/schedules/:scheduleId` | Owner + ownership | Delete a schedule entry |
| `POST` | `/api/courts/:courtId/blocked-slots` | Owner + ownership | Block a slot |
| `GET` | `/api/courts/:courtId/blocked-slots` | Owner + ownership | List blocked slots (optional date filter) |
| `DELETE` | `/api/courts/:courtId/blocked-slots/:blockedSlotId` | Owner + ownership | Remove a blocked slot |
| `GET` | `/api/courts/:courtId/availability?date=YYYY-MM-DD` | Any | Get generated slots with availability status |

### Request / Response Shapes

**POST /api/courts/:courtId/schedules**
```json
{
  "dayOfWeek": 1,
  "startTime": "08:00",
  "endTime": "17:00",
  "slotLength": 60
}
```

**POST /api/courts/:courtId/blocked-slots**
```json
{
  "date": "2026-03-15",
  "startTime": "2026-03-15T13:00:00Z",
  "endTime": "2026-03-15T14:00:00Z",
  "reason": "Court resurfacing"
}
```

**GET /api/courts/:courtId/availability?date=2026-03-15**
Response `200`:
```json
{
  "courtId": "uuid",
  "date": "2026-03-15",
  "timezone": "America/Chicago",
  "slots": [
    { "startTime": "08:00", "endTime": "09:00", "status": "available" },
    { "startTime": "09:00", "endTime": "10:00", "status": "booked" },
    { "startTime": "13:00", "endTime": "14:00", "status": "blocked" }
  ]
}
```

## Data Model References

- `Schedule`: id, courtId, dayOfWeek, startTime (`HH:mm`), endTime (`HH:mm`), slotLength (30 or 60)
  - Unique constraint: `courtId + dayOfWeek`
- `BlockedSlot`: id, courtId, date, startTime (UTC timestamptz), endTime (UTC timestamptz), reason

## Edge Cases

- If no schedule exists for a given day of week, the court has no availability that day (returns empty slots).
- `startTime` must be before `endTime` in a schedule entry.
- Blocked slot times must fall within the court's schedule for that day (or the block is still valid but has no practical effect beyond the schedule window).
- Overlapping blocked slots for the same court and date should be rejected or merged.
- Deleting a schedule entry does not affect existing bookings on dates that already have `PENDING`/`APPROVED` bookings.

## Out of Scope

- Recurring blocked slots (e.g., block every Tuesday).
- Facility-level schedule inheritance (each court manages its own schedule).
- Holiday calendars.
- Dynamic slot pricing by time of day.
