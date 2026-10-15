# Code Review Checklist

This checklist is used by the reviewer agent (Week 3) to evaluate pull requests.

## Must Fix

These issues **block merge** and must be resolved before approval:

- [ ] **Missing role check** on a protected endpoint — every protected route must verify `user.role`.
- [ ] **Missing ownership check** on an owner endpoint — checking role alone is not enough; the user must own the resource.
- [ ] **SQL injection** or string concatenation in database queries — all queries must use Prisma's parameterized API.
- [ ] **Secrets in code, logs, or frontend** — API keys, passwords, tokens, database URLs must never appear in source, log output, or client bundles.
- [ ] **Personal data in logs** — full email addresses, phone numbers, or other PII must not appear in log output. Emails must be masked.
- [ ] **Missing input validation** — every endpoint must validate input with zod before executing business logic.
- [ ] **Broken or deleted tests** — existing tests must not be removed or left in a failing state without a valid replacement.
- [ ] **Double-booking protection bypassed** — the PostgreSQL exclusion constraint and associated application logic must remain intact.

## Should Fix

These issues are **strongly recommended** and should be fixed before merge unless there is a documented reason to defer:

- [ ] **Missing error handling** — service calls without try/catch at the controller level, or errors swallowed silently.
- [ ] **`console.log` instead of logger** — all log output must use the structured JSON logger, not `console.log` or `console.debug`.
- [ ] **Missing TypeScript types** — use of `any` where a proper type or `unknown` should be used.
- [ ] **Hardcoded values that should be config** — magic numbers, URLs, or settings that belong in environment variables or a config module.
- [ ] **Missing test for a business rule** — each business rule (R1-R9) should have at least one dedicated test.
- [ ] **Inconsistent naming conventions** — files, variables, types, and constants should follow the conventions in `docs/rules/coding.md`.
- [ ] **Missing request ID in log entries** — every log entry within a request context must include `requestId`.
