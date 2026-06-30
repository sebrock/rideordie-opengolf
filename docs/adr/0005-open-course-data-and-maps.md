# ADR 0005: Use Open Course Data and Open Map Components

## Status


Accepted

- **Date:** 2026-06-22
- **Decision owners:** sebrock
- **Reviewers:** sebrock



## Context

The app needs golf course discovery, venue maps, hole metadata, scorecard data, and community course enrichment. The project wants to avoid proprietary map and course-data lock-in.

Candidate sources include OpenGolfAPI, OpenStreetMap/OSM-derived data, Open Course Data Model, municipal open data, and direct community submissions.

## Decision

We will use open map components and normalize course data into an open internal model, with clear provenance for every field.

## Alternatives

- Commercial golf course API.
- Manual event-only course data entry.
- Proprietary map SDK.
- OpenStreetMap-only approach.

## Trade-offs

- Open data supports the project thesis but may be incomplete, especially outside the US.
- OSM/ODbL obligations require attribution and careful derived-data handling.
- Community submissions improve coverage but need moderation and provenance.

## License Review

- Review OpenGolfAPI terms.
- Review OSM/ODbL obligations.
- Review Open Course Data Model license.
- Review every Europe/global candidate source before ingestion.

## Security Review

- Validate imported data to avoid injection or malicious links.
- Moderate user-submitted evidence URLs.
- Prevent location data abuse where privacy-sensitive.

## Rollback Plan

If global data quality is insufficient, support manual course setup for the inaugural event while continuing source evaluation post-MVP.

## Implementation Plan

- Build data-source registry.
- Define canonical course schema.
- Add import adapters.
- Add user correction/enrichment workflow.
- Add review state and provenance fields.

## Validation

- Users can select or create a course for scoring.
- Course fields include source and review state.
- Maps render using open components.

## Follow-up Decisions

- Canonical schema version.
- Publication license for enriched dataset.
- Moderation model for course edits.

## References

- Course data-source registry
- Open Course Data Model
- OpenStreetMap/ODbL
