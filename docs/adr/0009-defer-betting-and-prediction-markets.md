# ADR 0009: Defer Betting and Prediction Markets

## Status


Accepted

- **Date:** 2026-06-30
- **Decision owners:** sebrock
- **Reviewers:** sebrock


## Context

The project has discussed betting or prediction markets around event-specific outcomes. This could create engagement but introduces legal, regulatory, age-gating, payment, fraud, and reputation risk.

## Decision

Explicitly defer betting and prediction market functionality from MVP until legal review, jurisdiction assessment, and product governance are complete.

## Alternatives

- Include betting in MVP.
- Implement only non-monetary predictions.
- Use third-party betting provider.
- Ban all prediction functionality permanently.

## Trade-offs

- Deferral protects MVP focus and reduces legal risk.
- Non-monetary predictions could preserve engagement without gambling risk.
- Sponsors and community members may be interested, but this should not compromise the event platform.

## License Review

- Review any prediction market libraries before use.
- Review third-party provider terms if considered.

## Security Review

- Betting would require strong fraud controls, identity controls, age/jurisdiction controls, and payment safeguards.
- None of this should be implemented casually.

## Rollback Plan

If any betting-related prototype exists, keep it out of production builds and remove from MVP release branches.

## Implementation Plan

- Mark all betting issues as post-MVP.
- Add legal-review required label before any work starts.
- Consider non-monetary prediction game ADR separately.

## Validation

- MVP contains no gambling/payment wagering functionality.
- README and Foundation Document clearly mark betting as deferred.

## Follow-up Decisions

- Are non-monetary predictions acceptable?
- Which jurisdictions matter for future legal review?
- Is there sponsor interest in compliant prediction mechanics?

## References

- Foundation Document
- SECURITY.md
