---
name: plan-feature
description: Write an implementation plan for one feature from its spec. Use when asked to plan a feature.
argument-hint: [feature name or spec file]
disable-model-invocation: true
---

Plan the feature: $ARGUMENTS

1. Read the feature spec in docs/specs/features/, plus docs/specs/product.md, docs/specs/api.md, docs/specs/data-model.md and the rules in docs/rules/.
2. If the spec is unclear or contradicts another spec, stop and list the questions.
3. Write docs/plans/<feature-name>.md with these sections:
   - Goal: one-sentence summary
   - Acceptance Criteria: from the spec
   - Changes: data model, API endpoints, backend logic, frontend components
   - Steps: small numbered steps, each testable on its own
   - Tests to add for each step, including the business rules it touches
   - Events to log (following docs/rules/logging.md)
   - Risks and open questions
   - Out of scope
4. Do not write code.
5. End by listing the steps and any open questions.
