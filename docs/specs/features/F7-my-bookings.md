# F7 -- My Bookings (Player View)

## Description

Players view their upcoming and past bookings with status and stored total price. They can cancel a booking before its start time (R6). Cancelling a booking frees the held slot so that other players can book it.

## User Stories

- **US-7.1** As a player, I want to see my upcoming bookings so that I know where and when I am playing.
- **US-7.2** As a player, I want to see my past bookings so that I have a history of my activity.
- **US-7.3** As a player, I want to cancel a booking before its start time so that I can free the slot if my plans change.
- **US-7.4** As a player, I want to see the stored total price on each booking so that I know what was quoted.

## Acceptance Criteria

### Listing Bookings

- Given an authenticated player, when they request their bookings, then only their own bookings are returned.
- Bookings are split or filterable into **upcoming** (start time in the future) and **past** (start time in the past).
- Each booking includes: id, court name, facility name, date, start/end time (displayed in facility timezone per R3), total price, status, reject reason (if rejected).
- Results are sorted by date descending (most recent / next upcoming first).

### Cancellation

- Given a booking with status `PENDING` or `APPROVED` and a start time in the future, when the player cancels it, then the status changes to `CANCELLED` and the slot is freed.
- Given a booking with a start time in the past, when the player attempts to cancel, then a `400 Bad Request` is returned (R6).
- Given a booking with status `REJECTED`, `CANCELLED`, or `EXPIRED`, when the player attempts to cancel, then a `400 Bad Request` is returned (invalid transition).
- Only the booking's own player can cancel it (R6). Another player attempting to cancel receives `403 Forbidden`.

### Slot Release

- When a booking is cancelled, the slot transitions from held to free. Other players can immediately see it as available and book it.

## API Endpoints

| Method | Path | Auth | Description |
|---|---|---|---|
| `GET` | `/api/my/bookings` | Player | List authenticated player's bookings |
| `GET` | `/api/my/bookings?status=PENDING&upcoming=true` | Player | Filter by status and time |
| `PATCH` | `/api/bookings/:id/cancel` | Player + ownership | Cancel a booking |

### Request / Response Shapes

**GET /api/my/bookings?upcoming=true**
Response `200`:
```json
{
  "bookings": [
    {
      "id": "uuid",
      "courtId": "uuid",
      "courtName": "Court A",
      "facilityId": "uuid",
      "facilityName": "Sunset Pickleball Club",
      "date": "2026-03-20",
      "startTime": "14:00",
      "endTime": "16:00",
      "timezone": "America/Chicago",
      "totalPrice": 5000,
      "status": "APPROVED",
      "rejectReason": null,
      "createdAt": "2026-03-06T10:30:00Z"
    }
  ]
}
```

**PATCH /api/bookings/:id/cancel**
No request body required.

Response `200`:
```json
{
  "id": "uuid",
  "status": "CANCELLED"
}
```

## Data Model References

- `Booking`: queried by `playerId` matching the authenticated user.
- Status transitions: `PENDING -> CANCELLED`, `APPROVED -> CANCELLED`.
- No new models introduced.

## Edge Cases

- Player cancels a `PENDING` booking: the owner never needs to act on it; the slot is freed.
- Player cancels an `APPROVED` booking minutes before start time: allowed as long as `startTime` has not passed. No grace period in MVP.
- Booking start time is exactly "now": treat as past (cannot cancel).
- Player has no bookings: return empty list with `200` status.
- A booking whose facility was deleted (cascade) will no longer appear in the list.

## Out of Scope

- Cancellation fees or penalties.
- Cancellation reason from the player.
- Rebooking assistance (suggest alternative slots after cancellation).
- Email or push notification on cancellation.
- Cancellation policy configuration per facility.
