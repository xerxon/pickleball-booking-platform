# Testing Rules

## Framework

- **Vitest** for all unit and integration tests.
- Test files are co-located with source: `booking-service.test.ts` lives next to `booking-service.ts`.

## Integration Tests

- Integration tests hit a **real test database** (not mocks).
- Each test run starts with a clean database state (use transactions or truncation between tests).
- Every API endpoint has **at least one integration test**.

## Coverage

- Target: **70% line coverage** on backend business logic (services, controllers).
- Coverage is checked in CI but does not block merges below threshold during early development.

## Business Rule Tests

Each business rule (R1 through R9) has dedicated tests that verify the rule is enforced:

- **R1**: Role-based access — players cannot access owner endpoints and vice versa.
- **R2**: Ownership — owner cannot access another owner's facilities/courts.
- **R3**: Published/unpublished visibility — players only see published facilities.
- **R4**: Booking time limits — max 2 consecutive hours, max 14 days ahead.
- **R5**: Price calculation — price stored at booking time matches schedule.
- **R6**: Booking lifecycle — valid state transitions only.
- **R7**: Schedule conflicts — blocked slots prevent new bookings.
- **R8**: Double-booking prevention — tested with two simultaneous requests, exactly one succeeds.
- **R9**: Cancellation rules — only valid cancellations are allowed.

## Double-Booking Test

The double-booking test must simulate **two concurrent requests** for the same slot and assert that exactly one succeeds and exactly one fails with a conflict error. This validates the PostgreSQL exclusion constraint.

## Ownership Tests

Verify that an owner **cannot** read, update, or delete resources belonging to another owner. Tests should cover facilities, courts, schedules, and booking decisions.

## Test Naming

```typescript
describe('BookingService', () => {
  it('should reject a booking that exceeds 2 hours', async () => {
    // ...
  });

  it('should calculate price from the schedule at booking time', async () => {
    // ...
  });
});
```

Use `describe` for the feature or module name. Use `it('should ...')` for individual behaviors.
