# F6 -- Booking Approval Workflow

## Description

Owners review pending booking requests for courts they own. They can approve or reject each booking with an optional reason. The booking status updates immediately and the player sees the new status on their next view. Only the court's owner can act on bookings for that court (R5).

## User Stories

- **US-6.1** As an owner, I want to see all bookings for my courts so that I can manage incoming requests.
- **US-6.2** As an owner, I want to filter bookings by date and status so that I can focus on what needs attention.
- **US-6.3** As an owner, I want to approve a pending booking so that the player's reservation is confirmed.
- **US-6.4** As an owner, I want to reject a pending booking with an optional reason so that I can communicate why.
- **US-6.5** As a player, I want to see the updated status of my booking immediately after the owner acts so that I know whether my request was accepted.

## Acceptance Criteria

### Viewing Bookings

- Given an authenticated owner, when they request bookings for their courts, then only bookings for courts they own are returned.
- Results can be filtered by `date`, `status`, and `courtId`.
- Results are sorted by date and start time (ascending).

### Approving

- Given a booking with status `PENDING`, when the owner approves it, then the status changes to `APPROVED` and a `200` response is returned.
- Given a booking with status other than `PENDING`, when the owner attempts to approve it, then a `400 Bad Request` is returned (invalid transition).
- The slot remains held after approval.

### Rejecting

- Given a booking with status `PENDING`, when the owner rejects it, then the status changes to `REJECTED` and the slot is freed.
- The owner may include a `rejectReason` (optional, free-text).
- Given a booking with status other than `PENDING`, when the owner attempts to reject it, then a `400 Bad Request` is returned.

### Authorization

- Given a user who is not the owner of the court, when they attempt to approve or reject a booking, then a `403 Forbidden` is returned (R5).
- Given a user with role `PLAYER`, when they attempt to approve or reject, then a `403 Forbidden` is returned.

## API Endpoints

| Method | Path | Auth | Description |
|---|---|---|---|
| `GET` | `/api/owner/bookings` | Owner | List bookings for owner's courts |
| `PATCH` | `/api/bookings/:id/approve` | Owner + ownership | Approve a pending booking |
| `PATCH` | `/api/bookings/:id/reject` | Owner + ownership | Reject a pending booking |

### Request / Response Shapes

**GET /api/owner/bookings?status=PENDING&date=2026-03-20**
Response `200`:
```json
{
  "bookings": [
    {
      "id": "uuid",
      "courtId": "uuid",
      "courtName": "Court A",
      "facilityName": "Sunset Pickleball Club",
      "playerName": "Jane Doe",
      "date": "2026-03-20",
      "startTime": "2026-03-20T14:00:00Z",
      "endTime": "2026-03-20T16:00:00Z",
      "totalPrice": 5000,
      "status": "PENDING",
      "createdAt": "2026-03-06T10:30:00Z"
    }
  ]
}
```

**PATCH /api/bookings/:id/reject**
```json
{
  "reason": "Court under maintenance that day"
}
```
Response `200`:
```json
{
  "id": "uuid",
  "status": "REJECTED",
  "rejectReason": "Court under maintenance that day"
}
```

## Data Model References

- `Booking.status`: transitions from `PENDING` to `APPROVED` or `REJECTED`.
- `Booking.rejectReason`: populated on rejection, null otherwise.
- Ownership check: `Booking -> Court -> Facility -> ownerId` must match the authenticated user.

## Edge Cases

- Owner approves a booking after the player has already cancelled it: `400 Bad Request` (status is no longer `PENDING`).
- Owner has multiple facilities with courts that have bookings: the `GET /api/owner/bookings` endpoint aggregates across all owned courts.
- Two owners exist, each with their own facilities: owner A cannot see or act on owner B's bookings.
- If the booking's start time is in the past, the owner can still reject it but approval should return `400` (no point approving a past booking).

## Out of Scope

- Bulk approve/reject multiple bookings at once.
- Automatic approval rules (e.g., auto-approve for returning players).
- Notifications to player when status changes.
- Owner-initiated bookings (owner booking on behalf of a player).
