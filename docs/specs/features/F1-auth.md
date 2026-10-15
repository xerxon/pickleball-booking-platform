# F1 -- Authentication and Authorization

## Description

Users register with an email, name, password, and a role choice (Player or Owner). After registration they log in to receive a JWT access token used on all subsequent requests. Every owner endpoint enforces **both** role check and resource ownership check.

## User Stories

- **US-1.1** As a visitor, I want to register as a Player or Owner so that I can use the platform.
- **US-1.2** As a registered user, I want to log in with my email and password so that I receive an access token.
- **US-1.3** As an authenticated user, I want my token validated on every request so that unauthorized access is blocked.
- **US-1.4** As an owner, I want the system to verify I own a resource before allowing me to modify it, so that other owners cannot interfere with my data.

## Acceptance Criteria

### Registration

- Given a visitor provides a valid email, name, password, and role (`PLAYER` or `OWNER`), when they submit the registration form, then a new user is created and a `201` response is returned with user info (no password hash).
- Given a visitor provides an email that already exists, when they submit registration, then a `409 Conflict` is returned.
- Given a visitor omits required fields or provides an invalid email, when they submit, then a `400 Bad Request` with field-level errors is returned.
- Password must be at least 8 characters.

### Login

- Given valid credentials, when the user logs in, then a JWT access token is returned.
- Given an incorrect password, when the user logs in, then a `401 Unauthorized` is returned with a generic message (no indication of which field is wrong).
- Given a non-existent email, when the user logs in, then a `401 Unauthorized` is returned with the same generic message.

### Authorization

- Given a request without a token or with an expired/malformed token, when any protected endpoint is called, then a `401 Unauthorized` is returned.
- Given an owner attempts to modify a facility they do not own, when the request is processed, then a `403 Forbidden` is returned.

## API Endpoints

| Method | Path | Auth | Description |
|---|---|---|---|
| `POST` | `/api/auth/register` | None | Create a new user |
| `POST` | `/api/auth/login` | None | Authenticate and receive JWT |
| `GET` | `/api/auth/me` | JWT | Return current user profile |

### Request / Response Shapes

**POST /api/auth/register**
```json
{
  "email": "player@example.com",
  "name": "Jane Doe",
  "password": "securepass",
  "role": "PLAYER"
}
```
Response `201`:
```json
{
  "id": "uuid",
  "email": "player@example.com",
  "name": "Jane Doe",
  "role": "PLAYER",
  "createdAt": "2026-01-01T00:00:00.000Z"
}
```

**POST /api/auth/login**
```json
{
  "email": "player@example.com",
  "password": "securepass"
}
```
Response `200`:
```json
{
  "token": "eyJhbGciOiJIUzI1NiIs..."
}
```

## Data Model References

- `User` model: id, email, name, passwordHash, role, createdAt, updatedAt
- Passwords hashed with **bcrypt** before storage.
- JWT payload contains `userId` and `role`.

## Edge Cases

- Email comparison is case-insensitive (normalize to lowercase before storing).
- Role is immutable after registration. No endpoint exists to change it.
- Token expiry should be configurable (default: 24 hours).
- Concurrent registration with the same email: the unique constraint on `email` prevents duplicates; the second request receives `409`.

## Out of Scope

- Password reset / forgot password flow.
- OAuth / social login.
- Refresh tokens.
- Email verification.
- Role switching or multi-role users.
