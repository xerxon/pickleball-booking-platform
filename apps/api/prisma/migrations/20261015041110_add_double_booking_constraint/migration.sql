-- Enable btree_gist for exclusion constraints with non-GiST types
CREATE EXTENSION IF NOT EXISTS btree_gist;

-- Prevent overlapping bookings on the same court for active statuses (PENDING, APPROVED)
ALTER TABLE "bookings"
  ADD CONSTRAINT no_overlapping_bookings
  EXCLUDE USING gist (
    "courtId" WITH =,
    tstzrange("startTime", "endTime") WITH &&
  )
  WHERE (status IN ('PENDING', 'APPROVED'));
