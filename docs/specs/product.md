# Pickleball Booking Platform -- Product Spec

## Project Overview

The Pickleball Booking Platform connects players looking for court time with facility owners who manage pickleball venues. Players search for available courts, request bookings, and track their reservations. Owners register their facilities, define court schedules, and approve or reject incoming booking requests.

The platform is a full-stack web application built as a monorepo with two apps: a React front end and an Express API backed by PostgreSQL.

## Roles

Users choose one role at registration. The role is permanent.

| Role | Can do |
|---|---|
| **Player** | Search courts, request bookings, view and cancel own bookings |
| **Owner** | Create and manage facilities and courts, set schedules, block slots, approve/reject bookings for their own courts |

### Ownership Rule

Every owner-side endpoint checks **both** the user's role (`OWNER`) **and** that the authenticated user is the actual owner of the target resource (facility, court, schedule, booking). Role alone is never sufficient.

## Booking Lifecycle

```
(none) --> Pending --> Approved
                  \--> Rejected
                  \--> Cancelled
                  \--> Expired
```

| Status | Slot held? | Transition from | Who triggers |
|---|---|---|---|
| Pending | Yes | (none) | Player submits request |
| Approved | Yes | Pending | Owner approves |
| Rejected | No (freed) | Pending | Owner rejects |
| Cancelled | No (freed) | Pending, Approved | Player cancels |
| Expired | No (freed) | Pending | System (future: cron / TTL) |

A slot is considered **occupied** when a booking in `PENDING` or `APPROVED` status covers it. All other statuses free the slot.

## Business Rules

| ID | Rule |
|---|---|
| **R1** | A slot is free only if it falls within the court's opening hours, is not blocked, is not in the past, and is not held by a `PENDING` or `APPROVED` booking. |
| **R2** | A booking covers consecutive slots on a single court, up to 2 hours maximum, up to 14 days in advance. |
| **R3** | All times are stored in UTC. They are displayed to users in the facility's IANA timezone. |
| **R4** | Owners cannot block a slot that is currently held by a `PENDING` or `APPROVED` booking. |
| **R5** | Only the court's owner can approve or reject bookings for that court. |
| **R6** | Only the booking's player can cancel a booking (and only before the start time). |
| **R7** | Unpublished facilities (and their courts) are hidden from player search results and detail pages. |
| **R8** | Price = court hourly price x duration in hours. The total is calculated and stored at booking request time. |
| **R9** | No payment is recorded. Booking status is not dependent on any payment flow. |

## Assumptions

- Payment processing is handled externally and is outside the scope of this platform.
- Booking confirmations are in-app only; no email or SMS notifications in MVP.
- Court photos are stored as external URLs (no file upload service).
- All timestamps are stored in UTC; the facility's `timezone` field (IANA format) is used for display conversion.
- There is no admin super-role; owners manage only their own resources.

## MVP Scope

### Week 2 -- Core Features

| ID | Feature | Description |
|---|---|---|
| **F1** | Auth | Registration, login, JWT tokens, role selection |
| **F2** | Facilities | Facility and court CRUD for owners, draft/published state |
| **F3** | Schedules | Opening hours, slot generation, blocked slots |
| **F4** | Search | Full-text search by court, facility, or city; availability view |
| **F5** | Booking | Slot selection, double-booking prevention, price calculation |
| **F6** | Approval | Owner approval/rejection workflow |
| **F7** | My Bookings | Player booking list, cancellation |

### Week 3 -- Integration

| ID | Feature | Description |
|---|---|---|
| **F8** | Integration | End-to-end flows, error handling, loading states |

### Week 4 -- Polish

| ID | Feature | Description |
|---|---|---|
| **F9** | Logging | Request/response logging, audit trail |

## Tech Stack

| Layer | Technology |
|---|---|
| Front end | Vite + React (TypeScript) |
| Back end | Express (TypeScript) + Prisma ORM |
| Database | PostgreSQL |
| Auth | JWT (access tokens), bcrypt password hashing |
| Monorepo | pnpm workspaces |
| Runtime | Node.js >= 20 |

## Data Model (Summary)

| Model | Key fields |
|---|---|
| `User` | id, email, name, passwordHash, role (`PLAYER` / `OWNER`) |
| `Facility` | id, name, address, city, state, zipCode, timezone, isPublished, ownerId |
| `Court` | id, name, facilityId, isIndoor, surface, hourlyPrice (cents), photoUrl |
| `Schedule` | id, courtId, dayOfWeek (0-6), startTime, endTime, slotLength (30/60) |
| `BlockedSlot` | id, courtId, date, startTime, endTime, reason |
| `Booking` | id, courtId, playerId, date, startTime, endTime, totalPrice (cents), status, rejectReason |
