# F2 -- Facility and Court Management

## Description

Owners create and manage facilities (venues) and the courts within them. Each facility has a draft/published toggle. Unpublished facilities are invisible to players (R7). Every mutation endpoint verifies both the `OWNER` role and that the authenticated user owns the target facility.

## User Stories

- **US-2.1** As an owner, I want to create a facility with address and timezone so that I can list my venue.
- **US-2.2** As an owner, I want to add courts to my facility with pricing and surface details so that players can see what is available.
- **US-2.3** As an owner, I want to publish or unpublish my facility so that I can control when players can discover it.
- **US-2.4** As an owner, I want to edit or delete my facility and courts so that information stays current.
- **US-2.5** As a player, I want to see only published facilities so that I am not shown incomplete listings.

## Acceptance Criteria

### Facility CRUD

- Given an authenticated owner, when they create a facility with all required fields, then a `201` response is returned with the new facility.
- Given an authenticated owner, when they update their own facility, then a `200` response is returned with the updated facility.
- Given an authenticated owner, when they delete their own facility, then all related courts, schedules, blocked slots, and bookings are cascade-deleted.
- Given a user with the `PLAYER` role, when they attempt to create/update/delete a facility, then a `403 Forbidden` is returned.
- Given an owner, when they attempt to modify a facility owned by another owner, then a `403 Forbidden` is returned.

### Published State

- A facility defaults to `isPublished = false` (draft).
- Given an owner, when they set `isPublished` to `true`, then the facility appears in player search results.
- Given an owner, when they set `isPublished` to `false`, then the facility is hidden from all player-facing queries.

### Court CRUD

- Given an authenticated owner of a facility, when they add a court, then the court is linked to that facility.
- `hourlyPrice` is stored in cents (integer). The API accepts and returns cents.
- `photoUrl` is optional; it holds an external image URL.
- Given a court is deleted, then its schedules, blocked slots, and bookings are cascade-deleted.

## API Endpoints

| Method | Path | Auth | Description |
|---|---|---|---|
| `POST` | `/api/facilities` | Owner | Create facility |
| `GET` | `/api/facilities` | Any | List facilities (owners see own; players see published) |
| `GET` | `/api/facilities/:id` | Any | Get facility detail (players: published only) |
| `PUT` | `/api/facilities/:id` | Owner + ownership | Update facility |
| `DELETE` | `/api/facilities/:id` | Owner + ownership | Delete facility |
| `POST` | `/api/facilities/:facilityId/courts` | Owner + ownership | Add court |
| `GET` | `/api/facilities/:facilityId/courts` | Any | List courts for facility |
| `GET` | `/api/facilities/:facilityId/courts/:courtId` | Any | Get court detail |
| `PUT` | `/api/facilities/:facilityId/courts/:courtId` | Owner + ownership | Update court |
| `DELETE` | `/api/facilities/:facilityId/courts/:courtId` | Owner + ownership | Delete court |

### Request / Response Shapes

**POST /api/facilities**
```json
{
  "name": "Sunset Pickleball Club",
  "address": "123 Main St",
  "city": "Austin",
  "state": "TX",
  "zipCode": "78701",
  "timezone": "America/Chicago"
}
```

**POST /api/facilities/:facilityId/courts**
```json
{
  "name": "Court A",
  "isIndoor": false,
  "surface": "hard",
  "hourlyPrice": 2500,
  "photoUrl": "https://example.com/court-a.jpg"
}
```

## Data Model References

- `Facility`: id, name, address, city, state, zipCode, timezone (IANA), isPublished, ownerId
- `Court`: id, name, facilityId, isIndoor, surface, hourlyPrice (cents), photoUrl
- Facility -> Court is 1:many with cascade delete.

## Edge Cases

- Timezone must be a valid IANA timezone string (e.g., `America/New_York`). Invalid values should return `400`.
- Deleting a facility with active (`PENDING`/`APPROVED`) bookings still cascades. Owners accept this responsibility.
- An owner listing facilities via `GET /api/facilities` sees their own facilities regardless of published state. A player sees only published facilities.
- `hourlyPrice` must be a positive integer.

## Out of Scope

- Facility images (facility-level photos vs. court photos).
- Multi-owner facilities.
- Facility analytics or dashboards.
- Geocoding addresses to lat/long.
