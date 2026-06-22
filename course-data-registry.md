# Ride or Die Scorecard — Course Data Source Registry

Status: draft v0.1  
Owner: Product / Data / License Review  
Last updated: 2026-06-22

This registry tracks candidate golf-course data sources for Ride or Die Scorecard. The goal is to build an open, auditable, user-correctable course-data layer that can support scoring, maps, course discovery, pre-event qualification, and community enrichment.

## Registry rules

1. Prefer openly licensed sources with clear reuse terms.
2. Treat every source as untrusted until license review is complete.
3. Do not import proprietary data into the open dataset unless the license explicitly allows redistribution.
4. Preserve source attribution, source URL, import timestamp, and contributor identity/provenance for every imported record.
5. Keep raw imported data separate from normalized canonical course records.
6. Use Open Course Data Model as the preferred canonical shape, but do not treat it as a data source by itself.
7. Use OpenStreetMap-derived data carefully because ODbL share-alike obligations may apply to derivative databases.
8. Support user-submitted corrections, enrichment, and reviews with moderation and rollback.

## Summary table

| Source | Type | License / terms | Coverage region | Update method | Key fields | Current status | Risk notes |
|---|---|---:|---|---|---|---|---|
| OpenGolfAPI | Open dataset + API | ODbL 1.0 | Primarily United States; project states global ambition | GitHub release/files, API, community edits | Course name, GPS coordinates, scorecards, tee data, contact info, course metadata | Candidate baseline for US A/B test | ODbL attribution/share-alike obligations; limited Europe/global coverage today |
| OpenStreetMap | Open geodata source | ODbL 1.0 | Global, including Europe, Czech Republic, Germany, El Salvador where mapped | Overpass API, planet/geofabrik extracts, community OSM updates | Course polygons/points, names, addresses, tags, facilities, location geometry | Primary open global fallback | Sparse/inconsistent golf-specific scorecard data; ODbL database obligations; tag inconsistency |
| OSM-derived golf extracts | Derived datasets/tools | Usually ODbL if based on OSM; confirm per project | Depends on extract; often regional/global | Periodic OSM extraction via Overpass, Geofabrik, custom scripts | Filtered `leisure=golf_course`, geometry, names, selected tags | Candidate import pipeline artifact | Must preserve OSM attribution and licensing; generated extracts can become stale |
| Open Course Data Model | Schema / data model | Stated as open standard; verify exact license before embedding verbatim | Universal schema, not coverage-specific | Manual schema adoption and transformations | Course, hole, tee, par, hazards, yardage-style structured fields | Preferred canonical model candidate | Schema is not data; license/version stability must be verified in ADR/license review |
| GolfCourse API | Free API service | Free access claimed; redistribution/license unclear until reviewed | Claims almost 30,000 courses worldwide | API after signup | Course lookup fields, likely course details depending on API tier/docs | Candidate global discovery/enrichment source | “Free API” does not equal open data; terms may restrict redistribution/open dataset use |
| GolfAPI.io | Commercial API/export | Proprietary/commercial terms | Claims 42,000+ courses in 100+ countries | REST API and CSV export | Clubs, courses, pars/indexes, tees, lengths, slope/course ratings, coordinates/POIs | Candidate commercial fallback only | Not open-source/open-data aligned; do not import into open dataset without explicit redistribution rights |
| iGolf | Commercial data provider | Proprietary/commercial terms | Claims 40,000+ courses across 175+ countries | Licensed platform/API/data feed | Structured course data, GPS/layout data, global directory metadata | Candidate sponsor/paid validation source only | Strong coverage but likely incompatible with open redistribution by default |
| Golf Intelligence / similar paid APIs | Commercial data provider | Proprietary/commercial terms | Global / broad golf-data market | Licensed API | Scorecards, GPS, imagery, elevation/green data depending on product | Candidate reference/sponsor source only | Proprietary; may create vendor lock-in; imagery/elevation licensing risk |
| National golf federations and club directories | Regional official/semi-official lists | Usually website terms/copyright; verify case by case | Country-specific; Europe candidates include Germany/Czech Republic federations | Manual research, permission request, formal data partnership | Club names, addresses, contacts, federated status, sometimes ratings | Candidate validation and outreach source | Scraping may violate terms; official lists may not allow redistribution |
| Municipal / open government portals | Regional open data | Varies by portal; often CC BY, ODbL, national open-data licenses, or custom terms | Local/city/regional | API/CSV/GeoJSON download | Public facility names, addresses, parcels, boundaries, amenities | Candidate supplemental source | Coverage fragmented; licenses differ; often lacks scorecards/tee data |
| Direct club/community submissions | User-generated data | Project contribution license required | Global, wherever users contribute | In-app forms, import tools, moderation workflow | Full course profile, holes, tee sets, par, local rules, photos/links if licensed | Core long-term enrichment model | Needs contributor license terms, abuse controls, moderation, provenance, rollback |

## Source records

### DS-001 — OpenGolfAPI

**Purpose:** US baseline dataset for course discovery, scorecard seeding, and A/B comparison against Europe/global availability.

**License:** ODbL 1.0 according to the project materials. Requires attribution and careful handling of derivative database obligations.

**Coverage region:** Primarily United States. The project positions itself as an open database for golf courses worldwide, starting with US coverage.

**Update method:**

- GitHub repository files/releases.
- API where available.
- Community-maintained corrections.
- Scheduled import job should record source version, checksum, import date, and source URL.

**Likely fields:**

- Course name
- GPS coordinates
- Scorecards
- Tee data
- Contact information
- Course metadata
- Export formats such as CSV, GeoJSON, NDJSON, depending on source release

**Risk notes:**

- Strong US fit, weak Europe/global fit today.
- ODbL obligations need an ADR before combining with non-ODbL data.
- Must not silently merge into a proprietary database.
- Needs deduplication against OSM and user-submitted courses.

**Initial project use:** US A/B test dataset.

---

### DS-002 — OpenStreetMap

**Purpose:** Global open geodata fallback for course location, boundaries, maps, venue discovery, and regional coverage where detailed golf datasets are missing.

**License:** ODbL 1.0.

**Coverage region:** Global. Quality varies by region and local contributor activity.

**Update method:**

- Overpass API for targeted queries.
- Geofabrik or other OSM extracts for batch import.
- Periodic scheduled refresh by region.
- Manual validation for event venues.

**Likely fields:**

- Name
- Geometry: node, way, relation, polygon
- Coordinates / boundary
- Address tags where available
- Website/contact tags where available
- OSM object ID/version/timestamp
- Tags such as `leisure=golf_course` and related facility metadata

**Risk notes:**

- Good for “where is the course?” but usually poor for full scorecard data.
- Tagging can be inconsistent.
- ODbL share-alike obligations must be understood before publication.
- Some courses may be mapped as facilities without hole-level detail.

**Initial project use:** Europe/global discovery and map layer, including Germany, Czech Republic, and El Salvador pilots.

---

### DS-003 — OSM-derived golf extracts and tools

**Purpose:** Pre-filtered OSM golf-course extracts can speed up import, regional coverage analysis, and map rendering.

**License:** Usually ODbL if derived from OSM. Confirm per repository or distribution.

**Coverage region:** Depends on extract. Some projects cover North America only; project-generated extracts can cover any region.

**Update method:**

- Generate internally from OSM extracts using scripted filters.
- Optionally evaluate external projects such as OSM golf viewers/extractors.
- Refresh on a fixed cadence or before event planning milestones.

**Likely fields:**

- OSM ID
- Name
- Geometry
- Country/region
- OSM tags
- Optional derived centroid/bounding box

**Risk notes:**

- External extracts may be stale.
- Derived data inherits OSM license obligations.
- Project should prefer reproducible internal extract scripts over opaque third-party dumps.

**Initial project use:** Data availability benchmark for Europe/global regions.

---

### DS-004 — Open Course Data Model

**Purpose:** Candidate canonical schema for normalized course data across sources.

**License:** Publicly described as a free open standard. Exact license/version should be captured in license review before copying schema text into the repository.

**Coverage region:** Universal schema only. It does not provide course records.

**Update method:**

- Adopt as canonical schema or inspiration.
- Track schema version in ADR.
- Transform source-specific records into project-owned normalized records.

**Likely fields:**

- Course
- Hole
- Tee set
- Par
- Yardage/distance
- Hazards
- Facility/course metadata

**Risk notes:**

- It is not a dataset.
- Schema compatibility with ODbL and user-generated records needs review.
- Do not overfit MVP to a schema that may not cover match-play/event-specific scoring needs.

**Initial project use:** ADR candidate for canonical course model.

---

### DS-005 — GolfCourse API

**Purpose:** Candidate global discovery/enrichment API for coverage comparison and possible non-open reference checks.

**License:** Claims free API access, but open-data redistribution rights are not confirmed.

**Coverage region:** Claims almost 30,000 courses worldwide.

**Update method:**

- API access after signup.
- Use only in sandbox until license review is complete.

**Likely fields:**

- Course lookup metadata
- Location
- Course details depending on API documentation and tier

**Risk notes:**

- Free access is not the same as open license.
- Do not import into the open dataset until terms explicitly allow redistribution and derivative publication.
- Could be useful for QA comparisons without storing restricted data.

**Initial project use:** Candidate global coverage benchmark only.

---

### DS-006 — GolfAPI.io

**Purpose:** Candidate commercial fallback for global course data if open data is insufficient and a sponsor/paid license is acceptable for event operations.

**License:** Commercial/proprietary. Review required.

**Coverage region:** Claims 42,000+ courses in 100+ countries.

**Update method:**

- Licensed CSV export.
- REST API.

**Likely fields:**

- Clubs
- Courses
- Pars
- Stroke indexes
- Tee data
- Tee lengths
- Slope and course ratings
- Coordinates of greens and points of interest

**Risk notes:**

- Likely incompatible with the project’s open dataset unless special terms are negotiated.
- Could create vendor lock-in.
- Must be clearly separated from open-source/open-data deliverables.

**Initial project use:** Not MVP unless sponsor provides open-compatible terms.

---

### DS-007 — iGolf

**Purpose:** High-coverage commercial reference source for global golf-course data, especially if open data gaps block operational readiness.

**License:** Commercial/proprietary. Review required.

**Coverage region:** Claims 40,000+ courses across 175+ countries.

**Update method:**

- Licensed data feed/API/platform.
- Formal partnership or sponsorship required.

**Likely fields:**

- Course directory data
- GPS/layout data
- Facility metadata
- Structured course records

**Risk notes:**

- Coverage is attractive, but licensing may conflict with open-source/open-data mission.
- Do not combine with open database unless license explicitly permits publication.
- Could serve as a private validation source only if terms allow.

**Initial project use:** Sponsor outreach candidate, not open baseline.

---

### DS-008 — National golf federations and club directories

**Purpose:** Country-specific validation and venue discovery, especially for Germany, Czech Republic, Austria, Switzerland, and El Salvador pilots.

**License:** Unknown per federation. Usually not open by default.

**Coverage region:** Country-specific.

**Update method:**

- Manual research.
- Permission request.
- Formal partnership.
- Avoid scraping unless terms permit it.

**Likely fields:**

- Club/course names
- Addresses
- Websites
- Contact details
- Federation status
- Sometimes ratings or course information

**Risk notes:**

- Website lists are often copyrighted.
- Terms may block automated scraping or redistribution.
- Best used for outreach and manual verification unless data license is granted.

**Initial project use:** Validation/outreach, not automated MVP import.

---

### DS-009 — Municipal and open government portals

**Purpose:** Supplemental open location/facility data for public or municipal courses.

**License:** Varies by jurisdiction and portal.

**Coverage region:** Local/city/regional.

**Update method:**

- API/CSV/GeoJSON download where available.
- Manual review of license and update cadence.

**Likely fields:**

- Facility name
- Address/location
- Parcel/boundary geometry
- Ownership/operator
- Amenities

**Risk notes:**

- Fragmented coverage.
- Usually lacks golf scorecards, tee sets, slope, and rating.
- License compatibility must be checked source by source.

**Initial project use:** Supplemental enrichment for specific host regions.

---

### DS-010 — Direct club and community submissions

**Purpose:** Long-term global enrichment path aligned with the app’s open-source and community-driven thesis.

**License:** Project-defined contribution terms required.

**Coverage region:** Global.

**Update method:**

- In-app correction proposals.
- Course steward/moderator review.
- Club-owner verification.
- Nostr identity provenance and optional attestations.

**Likely fields:**

- Course profile
- Holes
- Tee sets
- Par
- Yardage/meters
- Local rules
- Course conditions/ratings
- Evidence links
- Contributor notes

**Risk notes:**

- Needs anti-spam and moderation.
- Needs clear contributor license agreement or Developer Certificate of Origin style language for data.
- Needs rollback/history.
- Needs proof/evidence requirements for sensitive edits.

**Initial project use:** MVP user story for proposing corrections; review/publish can be post-MVP if needed.

## Canonical fields to track per imported record

Every imported or user-submitted course record should store:

- `source_id`
- `source_record_id`
- `source_url`
- `source_license`
- `source_version`
- `imported_at`
- `raw_payload_hash`
- `normalized_record_id`
- `normalized_schema_version`
- `confidence_status`: unverified, imported, community-reviewed, club-verified, tournament-verified
- `attribution_text`
- `provenance_notes`
- `last_reviewed_at`
- `reviewer_npub` where applicable

## Proposed MVP data-source policy

### MVP allowed

- Use OpenGolfAPI for US A/B test imports after ODbL review.
- Use OSM/Overpass for Europe/global discovery and maps after ODbL review.
- Use Open Course Data Model as a candidate schema after license review.
- Allow users to propose course corrections and enrichment with provenance.

### MVP not allowed without explicit review

- Import commercial API/export data into the open database.
- Scrape federation or club websites without permission or compatible terms.
- Mix proprietary course records into ODbL/open records without clear database separation.
- Accept user-submitted photos, maps, or copied scorecards unless contribution rights are clear.

## Candidate A/B coverage tests

### Test A — United States

Primary source: OpenGolfAPI  
Secondary source: OSM  
Goal: Measure completeness of course identity, coordinates, scorecards, tee sets, par, slope/rating, and deduplication accuracy.

### Test B — Europe

Primary source: OSM/OSM-derived extracts  
Secondary source: national federation/club directory validation where permitted  
Target countries: Germany, Czech Republic, Austria, Switzerland  
Goal: Measure availability of course location vs full scorecard data and identify manual/community enrichment needs.

### Test C — El Salvador / Bitcoin-relevant pilot

Primary source: OSM  
Secondary source: direct club outreach / manual verification  
Goal: Evaluate feasibility of supporting a Bitcoin-aligned region with sparse open golf metadata.

## Review checklist for adding a new source

- [ ] Source has stable URL and owner/operator identified.
- [ ] License terms are captured and linked.
- [ ] Redistribution rights are understood.
- [ ] Commercial use rights are understood.
- [ ] Attribution requirements are documented.
- [ ] Share-alike/database obligations are documented.
- [ ] Update method is documented.
- [ ] Fields are mapped to canonical schema.
- [ ] Risk notes are added.
- [ ] ADR required if source affects architecture, licensing, or canonical schema.
- [ ] `license-review/required` label added to related issue/PR.
- [ ] `security-review/required` label added if API credentials, scraping, user data, or automated imports are involved.

## Open decisions

1. Should the project publish a combined ODbL-compatible course database, or keep source-specific layers separate?
2. Should user-submitted course data use ODbL, CC BY, CC0, or a custom contributor agreement?
3. Should Open Course Data Model be adopted directly or used only as inspiration for a project-owned schema?
4. What minimum evidence is required for community course-data edits?
5. How should club-owner verification work with Nostr identity?
6. What is the rollback process for bad course-data edits?
7. Which regions define the first Europe/global pilot: Germany, Czech Republic, Austria, Switzerland, El Salvador?

## References

- OpenGolfAPI repository and data files
- OpenGolfAPI public course browser/API materials
- OpenStreetMap license and legal FAQ
- OpenStreetMap Overpass API documentation
- Open Course Data Model materials
- GolfCourse API public materials
- GolfAPI.io public documentation
- iGolf public course-data materials
