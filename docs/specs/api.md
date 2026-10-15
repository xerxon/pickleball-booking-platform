# REST API Specification

Base URL: `/api`

## Authentication

All protected endpoints require a JWT token in the `Authorization` header:

```
Authorization: Bearer <token>
```

## Common Response Formats

### Error Response

```json
{
  "error": "Human-readable error message",
  "details": {}
}
```

| Status Code | Meaning                                      |
| ----------- | -------------------------------------------- |
| 400         | Bad request / validation error               |
| 401         | Missing or invalid token                     |
| 403         | Forbidden (wrong role or not resource owner)  |
| 404         | Resource not found                           |
| 409         | Conflict (e.g. overlapping booking)          |
| 500         | Internal server error                        |

### Paginated Response

```json
{
  "data": [],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 58,
    "totalPages": 3
  }
}
```

---

## Auth

### POST /api/auth/register

Create a new user account.

- **Auth:** none
- **Status:** `201 Created`

**Request body:**

```json
{
  "email": "player@example.com",
  "password": "securePassword1!",
  "name": "Jane Smith",
  "role": "PLAYER"
}
```

| Field    | Type   | Required | Notes                    |
| -------- | ------ | -------- | ------------------------ |
| email    | string | yes      | Must be unique           |
| password | string | yes      | Min 8 characters         |
| name     | string | yes      |                          |
| role     | string | yes      | `"PLAYER"` or `"OWNER"` |

**Response body:**

```json
{
  "id": "uuid",
  "email": "player@example.com",
  "name": "Jane Smith",
  "role": "PLAYER",
  "createdAt": "2026-01-15T10:00:00.000Z"
}
```

### POST /api/auth/login

Authenticate and receive a JWT token.

- **Auth:** none
- **Status:** `200 OK`

**Request body:**

```json
{
  "email": "player@example.com",
  "password": "securePassword1!"
}
```

**Response body:**

```json
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "user": {
    "id": "uuid",
    "email": "player@example.com",
    "name": "Jane Smith",
    "role": "PLAYER"
  }
}
```

| Status | Condition             |
| ------ | --------------------- |
| 200    | Success               |
| 401    | Invalid credentials   |

### POST /api/auth/logout

Invalidate the current token.

- **Auth:** Bearer token
- **Status:** `200 OK`

**Response body:**

```json
{
  "message": "Logged out successfully"
}
```

### GET /api/auth/me

Return the currently authenticated user.

- **Auth:** Bearer token
- **Status:** `200 OK`

**Response body:**

```json
{
  "id": "uuid",
  "email": "player@example.com",
  "name": "Jane Smith",
  "role": "PLAYER",
  "createdAt": "2026-01-15T10:00:00.000Z",
  "updatedAt": "2026-01-15T10:00:00.000Z"
}
```

---

## Facilities

### GET /api/facilities

Public list of published facilities with search and pagination.

- **Auth:** none
- **Status:** `200 OK`

**Query parameters:**

| Param  | Type   | Default | Notes                                |
| ------ | ------ | ------- | ------------------------------------ |
| search | string |         | Searches name and address            |
| city   | string |         | Filter by city (case-insensitive)    |
| page   | int    | 1       |                                      |
| limit  | int    | 20      | Max 100                              |

**Response:** paginated list of facilities.

```json
{
  "data": [
    {
      "id": "uuid",
      "name": "Sunset Pickleball Club",
      "address": "123 Main St",
      "city": "Austin",
      "state": "TX",
      "zipCode": "78701",
      "timezone": "America/Chicago",
      "isPublished": true,
      "ownerId": "uuid",
      "createdAt": "2026-01-15T10:00:00.000Z",
      "updatedAt": "2026-01-15T10:00:00.000Z"
    }
  ],
  "meta": { "page": 1, "limit": 20, "total": 5, "totalPages": 1 }
}
```

### GET /api/facilities/:id

Public detail for a single facility, including its courts.

- **Auth:** none
- **Status:** `200 OK`

**Response body:**

```json
{
  "id": "uuid",
  "name": "Sunset Pickleball Club",
  "address": "123 Main St",
  "city": "Austin",
  "state": "TX",
  "zipCode": "78701",
  "timezone": "America/Chicago",
  "isPublished": true,
  "ownerId": "uuid",
  "courts": [
    {
      "id": "uuid",
      "name": "Court 1",
      "isIndoor": false,
      "surface": "hard",
      "hourlyPrice": 2500,
      "photoUrl": null
    }
  ],
  "createdAt": "2026-01-15T10:00:00.000Z",
  "updatedAt": "2026-01-15T10:00:00.000Z"
}
```

| Status | Condition       |
| ------ | --------------- |
| 200    | Found           |
| 404    | Not found       |

### POST /api/facilities

Create a new facility.

- **Auth:** Bearer token, `OWNER` role
- **Status:** `201 Created`

**Request body:**

```json
{
  "name": "Sunset Pickleball Club",
  "address": "123 Main St",
  "city": "Austin",
  "state": "TX",
  "zipCode": "78701",
  "timezone": "America/Chicago",
  "isPublished": false
}
```

| Field       | Type    | Required | Notes                              |
| ----------- | ------- | -------- | ---------------------------------- |
| name        | string  | yes      |                                    |
| address     | string  | yes      |                                    |
| city        | string  | yes      |                                    |
| state       | string  | yes      |                                    |
| zipCode     | string  | yes      |                                    |
| timezone    | string  | yes      | IANA timezone (e.g. America/Chicago) |
| isPublished | boolean | no       | Defaults to `false`                |

**Response:** the created facility object.

| Status | Condition          |
| ------ | ------------------ |
| 201    | Created            |
| 400    | Validation error   |
| 401    | Not authenticated  |
| 403    | Not an OWNER       |

### PUT /api/facilities/:id

Update an existing facility. Only the owning user may update.

- **Auth:** Bearer token, `OWNER` role, must own the facility
- **Status:** `200 OK`

**Request body:** same fields as create (all optional for partial update).

| Status | Condition                          |
| ------ | ---------------------------------- |
| 200    | Updated                            |
| 400    | Validation error                   |
| 401    | Not authenticated                  |
| 403    | Not the owner of this facility     |
| 404    | Facility not found                 |

### DELETE /api/facilities/:id

Delete a facility and all associated courts, schedules, blocked slots, and bookings (cascade).

- **Auth:** Bearer token, `OWNER` role, must own the facility
- **Status:** `204 No Content`

| Status | Condition                          |
| ------ | ---------------------------------- |
| 204    | Deleted                            |
| 401    | Not authenticated                  |
| 403    | Not the owner of this facility     |
| 404    | Facility not found                 |

---

## Courts

### GET /api/facilities/:facilityId/courts

List all courts for a facility.

- **Auth:** none
- **Status:** `200 OK`

**Response body:**

```json
[
  {
    "id": "uuid",
    "name": "Court 1",
    "facilityId": "uuid",
    "isIndoor": false,
    "surface": "hard",
    "hourlyPrice": 2500,
    "photoUrl": null,
    "createdAt": "2026-01-15T10:00:00.000Z",
    "updatedAt": "2026-01-15T10:00:00.000Z"
  }
]
```

### POST /api/facilities/:facilityId/courts

Create a court under a facility.

- **Auth:** Bearer token, `OWNER` role, must own the facility
- **Status:** `201 Created`

**Request body:**

```json
{
  "name": "Court 1",
  "isIndoor": false,
  "surface": "hard",
  "hourlyPrice": 2500,
  "photoUrl": "https://example.com/photo.jpg"
}
```

| Field       | Type    | Required | Notes                         |
| ----------- | ------- | -------- | ----------------------------- |
| name        | string  | yes      |                               |
| isIndoor    | boolean | no       | Defaults to `false`           |
| surface     | string  | no       | Defaults to `"hard"`          |
| hourlyPrice | int     | yes      | Price in cents (e.g. 2500 = $25.00) |
| photoUrl    | string  | no       |                               |

| Status | Condition                         |
| ------ | --------------------------------- |
| 201    | Created                           |
| 400    | Validation error                  |
| 401    | Not authenticated                 |
| 403    | Not the owner of this facility    |
| 404    | Facility not found                |

### PUT /api/courts/:id

Update a court. Only the facility owner may update.

- **Auth:** Bearer token, `OWNER` role, must own the parent facility
- **Status:** `200 OK`

**Request body:** same fields as create (all optional).

| Status | Condition                             |
| ------ | ------------------------------------- |
| 200    | Updated                               |
| 400    | Validation error                       |
| 401    | Not authenticated                      |
| 403    | Not the owner of the parent facility   |
| 404    | Court not found                        |

### DELETE /api/courts/:id

Delete a court and its schedules, blocked slots, and bookings (cascade).

- **Auth:** Bearer token, `OWNER` role, must own the parent facility
- **Status:** `204 No Content`

| Status | Condition                             |
| ------ | ------------------------------------- |
| 204    | Deleted                                |
| 401    | Not authenticated                      |
| 403    | Not the owner of the parent facility   |
| 404    | Court not found                        |

---

## Schedules

Weekly recurring availability windows for a court.

### GET /api/courts/:courtId/schedules

List all schedule entries for a court.

- **Auth:** none
- **Status:** `200 OK`

**Response body:**

```json
[
  {
    "id": "uuid",
    "courtId": "uuid",
    "dayOfWeek": 1,
    "startTime": "08:00",
    "endTime": "20:00",
    "slotLength": 60
  }
]
```

### POST /api/courts/:courtId/schedules

Create a schedule entry for a court. One entry per day-of-week per court.

- **Auth:** Bearer token, `OWNER` role, must own the parent facility
- **Status:** `201 Created`

**Request body:**

```json
{
  "dayOfWeek": 1,
  "startTime": "08:00",
  "endTime": "20:00",
  "slotLength": 60
}
```

| Field      | Type   | Required | Notes                                    |
| ---------- | ------ | -------- | ---------------------------------------- |
| dayOfWeek  | int    | yes      | 0 = Sunday, 6 = Saturday                |
| startTime  | string | yes      | `"HH:mm"` in local facility time        |
| endTime    | string | yes      | `"HH:mm"` in local facility time        |
| slotLength | int    | no       | 30 or 60 minutes; defaults to 60        |

| Status | Condition                             |
| ------ | ------------------------------------- |
| 201    | Created                               |
| 400    | Validation error                      |
| 401    | Not authenticated                     |
| 403    | Not the owner of the parent facility  |
| 404    | Court not found                       |
| 409    | Schedule already exists for this day  |

### PUT /api/schedules/:id

Update a schedule entry.

- **Auth:** Bearer token, `OWNER` role, must own the parent facility
- **Status:** `200 OK`

| Status | Condition                             |
| ------ | ------------------------------------- |
| 200    | Updated                               |
| 400    | Validation error                      |
| 401    | Not authenticated                     |
| 403    | Not the owner of the parent facility  |
| 404    | Schedule not found                    |

### DELETE /api/schedules/:id

Delete a schedule entry.

- **Auth:** Bearer token, `OWNER` role, must own the parent facility
- **Status:** `204 No Content`

| Status | Condition                             |
| ------ | ------------------------------------- |
| 204    | Deleted                               |
| 401    | Not authenticated                     |
| 403    | Not the owner of the parent facility  |
| 404    | Schedule not found                    |

---

## Blocked Slots

One-off time ranges when a court is unavailable (maintenance, private events, etc.).

### GET /api/courts/:courtId/blocked-slots

List all blocked slots for a court.

- **Auth:** none
- **Status:** `200 OK`

**Response body:**

```json
[
  {
    "id": "uuid",
    "courtId": "uuid",
    "date": "2026-03-20",
    "startTime": "2026-03-20T13:00:00.000Z",
    "endTime": "2026-03-20T15:00:00.000Z",
    "reason": "Court resurfacing",
    "createdAt": "2026-01-15T10:00:00.000Z"
  }
]
```

### POST /api/courts/:courtId/blocked-slots

Block a time slot on a court.

- **Auth:** Bearer token, `OWNER` role, must own the parent facility
- **Status:** `201 Created`

**Request body:**

```json
{
  "date": "2026-03-20",
  "startTime": "2026-03-20T13:00:00.000Z",
  "endTime": "2026-03-20T15:00:00.000Z",
  "reason": "Court resurfacing"
}
```

| Field     | Type   | Required | Notes                          |
| --------- | ------ | -------- | ------------------------------ |
| date      | string | yes      | `YYYY-MM-DD`                   |
| startTime | string | yes      | ISO 8601 timestamp (UTC)       |
| endTime   | string | yes      | ISO 8601 timestamp (UTC)       |
| reason    | string | no       | Human-readable reason          |

| Status | Condition                             |
| ------ | ------------------------------------- |
| 201    | Created                               |
| 400    | Validation error                      |
| 401    | Not authenticated                     |
| 403    | Not the owner of the parent facility  |
| 404    | Court not found                       |

### DELETE /api/blocked-slots/:id

Remove a blocked slot.

- **Auth:** Bearer token, `OWNER` role, must own the parent facility
- **Status:** `204 No Content`

| Status | Condition                             |
| ------ | ------------------------------------- |
| 204    | Deleted                               |
| 401    | Not authenticated                     |
| 403    | Not the owner of the parent facility  |
| 404    | Blocked slot not found                |

---

## Availability

### GET /api/courts/:courtId/availability?date=YYYY-MM-DD

Compute available booking slots for a court on a given date. Combines the court's weekly schedule with existing bookings and blocked slots to return only open time windows.

- **Auth:** none
- **Status:** `200 OK`

**Query parameters:**

| Param | Type   | Required | Notes            |
| ----- | ------ | -------- | ---------------- |
| date  | string | yes      | `YYYY-MM-DD`    |

**Response body:**

```json
{
  "courtId": "uuid",
  "date": "2026-03-20",
  "slots": [
    {
      "startTime": "08:00",
      "endTime": "09:00",
      "available": true
    },
    {
      "startTime": "09:00",
      "endTime": "10:00",
      "available": false
    }
  ]
}
```

| Status | Condition            |
| ------ | -------------------- |
| 200    | Success              |
| 400    | Missing/invalid date |
| 404    | Court not found      |

---

## Bookings

### POST /api/bookings

Create a new booking request. Status starts as `PENDING`.

- **Auth:** Bearer token, `PLAYER` role
- **Status:** `201 Created`

**Request body:**

```json
{
  "courtId": "uuid",
  "date": "2026-03-20",
  "startTime": "2026-03-20T14:00:00.000Z",
  "endTime": "2026-03-20T15:00:00.000Z"
}
```

| Field     | Type   | Required | Notes                                                 |
| --------- | ------ | -------- | ----------------------------------------------------- |
| courtId   | string | yes      | UUID of the court                                     |
| date      | string | yes      | `YYYY-MM-DD`                                          |
| startTime | string | yes      | ISO 8601 timestamp (UTC)                              |
| endTime   | string | yes      | ISO 8601 timestamp (UTC)                              |

`totalPrice` is calculated server-side from the court's `hourlyPrice` and the booking duration.

**Response:** the created booking object.

| Status | Condition                                                 |
| ------ | --------------------------------------------------------- |
| 201    | Booking created (PENDING)                                 |
| 400    | Validation error (past date, outside schedule, etc.)      |
| 401    | Not authenticated                                        |
| 403    | Not a PLAYER                                              |
| 404    | Court not found                                          |
| 409    | Time slot conflicts with existing booking or blocked slot |

### GET /api/bookings

List the authenticated user's bookings with optional filters.

- **Auth:** Bearer token
- **Status:** `200 OK`

**Query parameters:**

| Param  | Type   | Default | Notes                                          |
| ------ | ------ | ------- | ---------------------------------------------- |
| status | string |         | Filter by `BookingStatus` value                |
| page   | int    | 1       |                                                |
| limit  | int    | 20      | Max 100                                        |

**Response:** paginated list of bookings.

```json
{
  "data": [
    {
      "id": "uuid",
      "courtId": "uuid",
      "playerId": "uuid",
      "date": "2026-03-20",
      "startTime": "2026-03-20T14:00:00.000Z",
      "endTime": "2026-03-20T15:00:00.000Z",
      "totalPrice": 2500,
      "status": "PENDING",
      "rejectReason": null,
      "createdAt": "2026-01-15T10:00:00.000Z",
      "updatedAt": "2026-01-15T10:00:00.000Z",
      "court": {
        "id": "uuid",
        "name": "Court 1",
        "facility": {
          "id": "uuid",
          "name": "Sunset Pickleball Club"
        }
      }
    }
  ],
  "meta": { "page": 1, "limit": 20, "total": 3, "totalPages": 1 }
}
```

### GET /api/bookings/:id

Get a single booking. Players see their own; owners see bookings at their facilities.

- **Auth:** Bearer token
- **Status:** `200 OK`

| Status | Condition                           |
| ------ | ----------------------------------- |
| 200    | Found                               |
| 401    | Not authenticated                   |
| 403    | Not the player or facility owner    |
| 404    | Booking not found                   |

### PATCH /api/bookings/:id/approve

Approve a pending booking.

- **Auth:** Bearer token, `OWNER` role, must own the facility the court belongs to
- **Status:** `200 OK`

**Request body:** none

**Response:** the updated booking with `status: "APPROVED"`.

| Status | Condition                               |
| ------ | --------------------------------------- |
| 200    | Approved                                |
| 400    | Booking is not in PENDING status        |
| 401    | Not authenticated                       |
| 403    | Not the owner of this facility          |
| 404    | Booking not found                       |

### PATCH /api/bookings/:id/reject

Reject a pending booking with an optional reason.

- **Auth:** Bearer token, `OWNER` role, must own the facility the court belongs to
- **Status:** `200 OK`

**Request body:**

```json
{
  "reason": "Court under maintenance that day"
}
```

| Field  | Type   | Required | Notes                 |
| ------ | ------ | -------- | --------------------- |
| reason | string | no       | Stored in rejectReason |

**Response:** the updated booking with `status: "REJECTED"`.

| Status | Condition                               |
| ------ | --------------------------------------- |
| 200    | Rejected                                |
| 400    | Booking is not in PENDING status        |
| 401    | Not authenticated                       |
| 403    | Not the owner of this facility          |
| 404    | Booking not found                       |

### PATCH /api/bookings/:id/cancel

Cancel a booking. Only the player who made the booking may cancel.

- **Auth:** Bearer token, `PLAYER` role, must be the booking's player
- **Status:** `200 OK`

**Request body:** none

**Response:** the updated booking with `status: "CANCELLED"`.

| Status | Condition                                         |
| ------ | ------------------------------------------------- |
| 200    | Cancelled                                         |
| 400    | Booking is already cancelled/rejected/expired     |
| 401    | Not authenticated                                 |
| 403    | Not the player who made this booking              |
| 404    | Booking not found                                 |

### GET /api/facilities/:facilityId/bookings

List all bookings for a facility. Only the facility owner can access this.

- **Auth:** Bearer token, `OWNER` role, must own the facility
- **Status:** `200 OK`

**Query parameters:**

| Param  | Type   | Default | Notes                           |
| ------ | ------ | ------- | ------------------------------- |
| status | string |         | Filter by `BookingStatus` value |
| page   | int    | 1       |                                 |
| limit  | int    | 20      | Max 100                         |

**Response:** paginated list of bookings for all courts in the facility.

| Status | Condition                          |
| ------ | ---------------------------------- |
| 200    | Success                            |
| 401    | Not authenticated                  |
| 403    | Not the owner of this facility     |
| 404    | Facility not found                 |
