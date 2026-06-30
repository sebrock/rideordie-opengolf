# ADR 0004: Require License Review Gates for Dependencies and Data Sources

## Status


Accepted

- **Date:** 2026-06-22
- **Decision owners:** sebrock
- **Reviewers:** sebrock



## Context

The project has a strict open-source-first requirement. Core dependencies, data sources, maps, wallet tools, Nostr libraries, and course data must be license-compatible.

The project also intends to use and potentially redistribute combined golf course data, which creates license and attribution risk.

## Decision

TBD.

Proposed direction: require explicit license review for new dependencies, data sources, generated assets, and any code or content with unclear reuse terms.

## Alternatives

- Informal contributor judgment.
- Review only before release.
- Use any free-to-access data/API as if it were open.
- Restrict all inputs to permissive licenses only.

## Trade-offs

- Review gates slow down early contributions but prevent major rework and legal ambiguity.
- ODbL/share-alike datasets may be useful but require careful compliance.
- Some useful APIs may be free but not redistributable.

## License Review

- Maintain a source/dependency registry.
- Require license-review labels on relevant issues and PRs.
- Track attribution and redistribution requirements.
- Separate open data from proprietary/reference-only data.

## Security Review

- License review is separate from security review, but third-party dependencies may require both.
- Avoid unmaintained packages with unknown provenance.

## Rollback Plan

If a dependency or data source fails review, remove it, replace it, or isolate it behind an optional adapter that is not part of the default open-source build.

## Implementation Plan

- Maintain `docs/data-sources/course-data-registry.md`.
- Add PR checklist for license review.
- Add issue template for license review.
- Document allowed and blocked data-use patterns.

## Validation

- Each new dependency has a known license.
- Each data source has documented terms and risk notes.
- Release artifacts do not include unreviewed proprietary data.

## Follow-up Decisions

- Final project license.
- Data license for project-generated course data.
- Policy for ODbL-derived database publication.

## References

- Course data-source registry
- CONTRIBUTING.md
