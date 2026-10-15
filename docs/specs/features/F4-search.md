# F4 -- Search and Discovery

## Description

Players discover courts through a single search box that matches against court name, facility name, or city. Results are paginated and show a photo, hourly price, and basic facility info. A detail page shows court information and availability for a selected date. Only published facilities appear in search results (R7).

## User Stories

- **US-4.1** As a player, I want to search for courts by name, facility, or city so that I can find places to play near me.
- **US-4.2** As a player, I want to see paginated results with a photo and hourly price so that I can quickly compare options.
- **US-4.3** As a player, I want to view a court's detail page with availability for a chosen date so that I can decide when to book.
- **US-4.4** As a player, I want to be sure I only see published facilities so that I am not shown incomplete or closed venues.

## Acceptance Criteria

### Search

- Given a player enters a search term, when results are returned, then courts whose name, facility name, or city match the term are included.
- Search is case-insensitive and uses substring matching (e.g., `LIKE '%term%'` or equivalent).
- Results only include courts belonging to published facilities (R7).
- Results are paginated with a default page size (e.g., 20) and support `page` and `limit` query parameters.
- Each result includes: court name, facility name, city, state, hourly price (cents), photo URL, surface type, indoor/outdoor.

### Detail Page

- Given a valid court ID belonging to a published facility, when a player requests the detail page, then court info and facility info are returned.
- Given a court ID belonging to an unpublished facility, when a player requests it, then a `404 Not Found` is returned.
- Given a `date` query parameter, when the detail page is loaded, then the availability slots for that date are included (delegates to the availability endpoint from F3).

### No Results

- Given a search term with no matches, when the player searches, then an empty list is returned with `200` status (not an error).

## API Endpoints

| Method | Path | Auth | Description |
|---|---|---|---|
| `GET` | `/api/search?q=term&page=1&limit=20` | Any (public) | Search courts by name, facility, or city |
| `GET` | `/api/facilities/:id` | Any | Facility detail (published only for players) |
| `GET` | `/api/facilities/:facilityId/courts/:courtId` | Any | Court detail (published facility only for players) |
| `GET` | `/api/courts/:courtId/availability?date=YYYY-MM-DD` | Any | Availability for a date (see F3) |

### Request / Response Shapes

**GET /api/search?q=austin&page=1&limit=20**
Response `200`:
```json
{
  "results": [
    {
      "courtId": "uuid",
      "courtName": "Court A",
      "facilityId": "uuid",
      "facilityName": "Sunset Pickleball Club",
      "city": "Austin",
      "state": "TX",
      "hourlyPrice": 2500,
      "photoUrl": "https://example.com/court-a.jpg",
      "surface": "hard",
      "isIndoor": false
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 1,
    "totalPages": 1
  }
}
```

## Data Model References

- Reads from `Court` joined with `Facility` (filtered by `isPublished = true` for players).
- No new models introduced.

## Edge Cases

- Empty search term (`q=` or `q` omitted): return all courts from published facilities, paginated.
- Special characters in search term should be escaped to prevent SQL injection (Prisma handles this by default with parameterized queries).
- If `page` exceeds total pages, return an empty results array.
- Owners searching see their own unpublished courts via the facility endpoints, not via the search endpoint.

## Out of Scope

- Geolocation-based search (distance from user).
- Filters by surface type, indoor/outdoor, price range.
- Sort options (by price, by distance, by rating).
- Saved searches or favorites.
- Full-text search indexing (e.g., PostgreSQL tsvector).
