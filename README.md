# Ride or Die Scorecard

**Ride or Die Scorecard is a Nostr-native, Bitcoin-powered golf event platform.**

The first deployment is the **Ride or Die Cup**: an on-site team golf tournament where players, scorekeepers, fans, sponsors, and developers interact through one open-source Progressive Web App.

The larger thesis is simple:

> Sporting events should not depend on closed scoring systems, proprietary identity, custodial payment rails, or locked-down event software.
>
> Ride or Die Scorecard explores what happens when event management, scoring, identity, rewards, and fan engagement are rebuilt around open protocols: **Nostr, Bitcoin, Lightning, open maps, and open data**.

This is not just a golf scorecard. It is a reference implementation for decentralized, community-owned event infrastructure.

---

## Project Thesis

Most amateur and semi-professional sporting events still run on a fragile mix of spreadsheets, chat groups, manual scorecards, proprietary tournament tools, and disconnected payment flows.

Ride or Die Scorecard aims to prove a different model:

1. **Identity should be portable.**
   Participants should be able to use Nostr identities instead of platform-owned accounts.

2. **Payments should be Bitcoin-native.**
   Registration fees, zaps, rewards, and sponsorship contributions should flow through Bitcoin and Lightning, preferably through non-custodial wallet connections.

3. **Event data should be open and composable.**
   Scores, achievements, course data, public updates, and attestations should be structured so other clients and services can build on top.

4. **The app should be usable at a real tournament.**
   This is not a protocol demo. The first target is a working golf event with registration, scorekeeping, live updates, and operational reliability.

5. **The stack should be open source by default.**
   Core components should avoid proprietary lock-in. Any dependency should be reviewed for license compatibility and long-term project fit.

---

## What We Are Building

Ride or Die Scorecard is a **Progressive Web App** for running and following a golf tournament.

At its core, the app combines:

- **Nostr identity** for players, team managers, scorers, organizers, and fans
- **Tournament registration** with team and player management
- **Bitcoin/Lightning payments** for fees, zaps, and rewards
- **Non-custodial wallet connectivity** through Nostr Wallet Connect / NIP-47 where feasible
- **Live golf scoring** for the on-site event
- **Pre-event qualification scoring** for players practicing at home courses
- **Peer or marker attestations** for submitted practice scores
- **Achievements, badges, and points** to increase engagement
- **Course data ingestion, correction, enrichment, and ratings**
- **Open-source, contributor-friendly development process**

---

## MVP Definition

The MVP should prove that the Ride or Die Cup can run on open, Bitcoin-native, Nostr-native software.

The MVP is successful if organizers can register players, assign teams, collect Lightning-based fee contributions, appoint scorers, record scores, show live standings, and publish public updates in a way that is usable at the real event.

### MVP Must Have

#### 1. Nostr-Based Identity

Users can sign in or identify themselves using a Nostr public key.

The MVP should support:

- Nostr public key based user identity
- Basic profile display
- Role assignment for organizers, players, team managers, scorers, and fans
- Linking a participant record to a Nostr identity

#### 2. Tournament Registration

Players and teams can be registered for the Ride or Die Cup.

The MVP should support:

- Player registration
- Team assignment
- Team manager role
- Organizer review and correction
- Participant list export or admin view

#### 3. Bitcoin/Lightning Fee Contribution

Players can contribute tournament fees using Bitcoin/Lightning.

The MVP should support:

- Payment request generation
- Payment status tracking
- Registration status update after payment confirmation
- Basic admin visibility into paid/unpaid participants

Preferred direction:

- Use BTCPay Server or another open-source Bitcoin payment component
- Use Nostr Wallet Connect / NIP-47 where practical
- Keep the app non-custodial: the app must not hold user funds, seed phrases, or raw private keys

#### 4. Scorekeeper Workflow

App usage does not need to be mandatory for every player. A dedicated scorekeeper can be appointed to track scores.

The MVP should support:

- Scorekeeper role
- Hole-by-hole score entry
- Score editing with audit trail
- Basic validation checks
- Submission confirmation

#### 5. Live Scoreboard

Fans, players, and organizers can follow tournament progress.

The MVP should support:

- Team standings
- Match or round status
- Live updates from score submissions
- Public read-only scoreboard view

#### 6. Course Data Baseline

The app needs enough course data to support the inaugural tournament and future expansion.

The MVP should support:

- Manual course creation
- Basic course fields: name, location, holes, par, tee information where available
- Import path for OpenStreetMap-derived data or other openly licensed datasets
- Source attribution and license tracking
- User correction and enrichment proposals
- Review status for submitted course data changes

#### 7. Progressive Web App

The app should work across common client types without requiring app-store distribution.

The MVP should support:

- Mobile browser usage
- Desktop browser usage
- Installable PWA behavior where feasible
- Responsive design
- Offline-tolerant score entry direction, even if full offline sync is post-MVP

#### 8. Accessibility Baseline

The MVP should be usable by a broad set of users.

The MVP should include:

- Keyboard navigation support
- Sufficient contrast
- Screen-reader friendly form labels
- Clear error messages
- Avoidance of color-only status indicators

---

## MVP Should Have

These features are valuable for the first release, but should not block the core tournament flow if delivery pressure increases.

- Pre-event practice score submission
- Peer or marker attestation for practice scores
- Team points from pre-event qualification activity
- Nostr badges or achievement records
- Zap-enabled public score posts
- Basic course ratings
- User-submitted course data corrections
- Sponsor visibility modules
- Simple export for event reports

---

## Post-MVP Ideas

These are important but should remain outside the first production-critical scope unless capacity allows.

- Betting or prediction markets
- Advanced achievement economy
- Rich social feed around score events
- Automated handicap or difficulty normalization
- Global course data federation
- Full offline-first scoring
- Multi-event and multi-sport support
- Native mobile apps
- Advanced sponsor dashboards
- Public APIs for third-party clients

Any betting or prediction-market functionality requires separate legal and compliance review before implementation.

---

## User Roles

### Organizer / Admin

Runs the event, manages users, teams, payments, schedule, and operational readiness.

### Product Manager

Maintains vision, MVP scope, roadmap, backlog, user stories, and prioritization.

### Player

Registers for the tournament, contributes fees, plays rounds, submits or confirms scores, earns points or badges.

### Team Manager

Coordinates a team, checks roster status, monitors team progress, and supports player communication.

### Scorekeeper

Records official scores during the event and submits score updates to the system.

### Marker / Attester

Confirms that a player-submitted pre-event score is accurate.

### Fan / Spectator

Follows live scores, zaps posts, views achievements, and engages with public event updates.

### Sponsor / Partner

Provides money, services, infrastructure, prizes, or technical support in exchange for visibility and ecosystem alignment.

### Developer / Contributor

Builds, reviews, tests, documents, and improves the open-source platform.

### UX Specialist

Ensures the app is simple, accessible, and usable under real tournament conditions.

### QA / Tester

Tests workflows, edge cases, device compatibility, score correctness, payment status handling, and event readiness.

---

## Core Product Areas

### Identity

- Nostr login and profile association
- Role management
- Permission boundaries
- Key and session handling

### Registration

- Player registration
- Team management
- Fee status
- Admin review

### Payments and Wallets

- Bitcoin/Lightning fee contributions
- Nostr Wallet Connect / NIP-47 support
- Zaps for public posts
- Rewards and sats distribution direction
- Non-custodial architecture

### Scoring

- Hole-by-hole score entry
- Scorekeeper workflow
- Score corrections
- Live standings
- Score history and auditability

### Pre-Event Qualification

- Practice score submission
- Home-course participation
- Peer or marker attestation
- Team points
- Badges and achievements

### Course Data

- Course import
- Course normalization
- Course correction proposals
- Community enrichment
- Ratings and quality signals
- Source/license tracking
- Contributor provenance and review status

### Fan Engagement

- Public scoreboard
- Score posts
- Zaps
- Achievements
- Event updates

### Sponsorship

- Sponsor visibility
- Infrastructure sponsorship
- Prize sponsorship
- Service contributions from Bitcoin/Nostr ecosystem projects

---

## Repository Setup

This repository should contain the core application code plus project governance material.

Recommended structure:

```text
.github/
  ISSUE_TEMPLATE/
    bug_report.yml
    feature_request.yml
    license_review.yml
    security_report.yml
    ux_review.yml
README.md
CONTRIBUTING.md
CODE_OF_CONDUCT.md
SECURITY.md
SUPPORT.md
```

The issue templates are intentionally structured. Use them instead of blank issues whenever possible.

---

## Issue Workflow

Issues should be small enough to review and test. Large ideas should be split into backlog epics or multiple implementation issues.

Use the label families consistently:

- `area/...` — product or technical area
- `priority/...` — sequencing importance
- `role/...` — likely contributor profile
- `license-review/required` — dependency or data source requires license review
- `security-review/required` — sensitive area requires security review
- `good-first-issue` — suitable for new contributors

Typical flow:

1. Create or pick an issue.
2. Confirm acceptance criteria.
3. Add area, priority, and role labels.
4. Add `license-review/required` for new dependencies, external datasets, map/course data sources, or sponsor-provided services.
5. Add `security-review/required` for identity, auth, wallet, payment, Nostr key handling, permissions, or infrastructure changes.
6. Open a focused pull request.
7. Link the pull request to the issue.
8. Close the issue only after acceptance criteria and review checks are satisfied.

---

## Issue Templates

Use these templates:

- **Feature request** — new product or technical capability
- **Bug report** — broken behavior or regression
- **Security review / vulnerability report** — security-sensitive work or responsible disclosure placeholder
- **License review** — dependency, dataset, tool, map layer, or hosted service review
- **UX review** — usability, accessibility, mobile/PWA, role-specific flows

Security vulnerabilities should follow `SECURITY.md`. Do not disclose exploitable vulnerabilities publicly unless maintainers have agreed to a disclosure path.

---

## Open Source Policy

The project should use open-source components wherever possible.

Every dependency should be reviewed for:

- License type
- Commercial compatibility
- Copyleft obligations
- Attribution requirements
- Data license compatibility
- Security posture
- Operational maturity

Labels such as `license-review/required` and `security-review/required` should be used for issues involving new dependencies, payment handling, wallet connections, identity, or external data ingestion.

---

## Technical Direction

The likely architecture is:

- **Frontend:** Progressive Web App
- **Identity:** Nostr public keys and signing flows
- **Wallet connectivity:** Nostr Wallet Connect / NIP-47 where feasible
- **Payments:** Bitcoin/Lightning, likely via BTCPay Server or compatible open-source components
- **Backend:** API layer for registration, scoring, tournament state, and data ingestion
- **Database:** Open-source relational database such as PostgreSQL
- **Live updates:** Nostr relays and/or backend push mechanism
- **Maps:** OpenStreetMap-compatible open-source mapping stack
- **Course data:** Openly licensed imports plus community correction/enrichment workflow
- **Deployment:** Containerized, reproducible, and contributor-friendly

---

## Development Environment

The project should support contributors using Linux, macOS, and Windows with WSL.

For Windows contributors, use **VS Code with WSL** rather than running shell scripts from PowerShell.

Recommended WSL flow:

```bash
# Open the repository inside WSL
cd ~/code/ride-or-die-scorecard

# Check tooling
git --version
python3 --version
gh --version

# Authenticate GitHub CLI if needed
gh auth login
```

If scripts fail because of Windows line endings, run:

```bash
find . -name "*.sh" -exec sed -i 's/\r$//' {} \;
find . -name "*.sh" -exec chmod +x {} \;
```

---

## Initial Sprint Direction

### Sprint 0: Project Foundation

Goal: make the project contribution-ready.

Focus:

- Repository setup
- README
- License
- Contribution guide
- Code of conduct
- Security policy
- Support policy
- Issue templates
- Label and issue structure
- Architecture decision records
- Open-source dependency review process

### Sprint 1: Identity and Registration

Goal: allow participants to identify and register.

Focus:

- Nostr identity prototype
- Basic user roles
- Player registration
- Team assignment
- Admin roster view

### Sprint 2: Course Data and Scoring Prototype

Goal: prove the core golf flow.

Focus:

- Course data model
- Manual course setup
- Scorekeeper score entry
- Score validation
- Basic leaderboard

### Sprint 3: Bitcoin/Lightning Payments

Goal: connect registration to Bitcoin-native fee contribution.

Focus:

- Payment component selection
- Lightning invoice generation or BTCPay integration
- Payment status tracking
- Paid/unpaid registration state
- Wallet connection research/prototype

### Sprint 4: Live Event Readiness

Goal: make the app usable during the on-site event.

Focus:

- Live scoreboard
- Score correction flow
- Role permissions
- PWA polish
- Accessibility pass
- Event-day test plan

### Sprint 5: Engagement and Data Enrichment

Goal: extend the platform beyond basic scoring.

Focus:

- Pre-event practice scoring
- Attestation flow
- Zaps on score posts
- Course ratings
- Course correction proposals
- Sponsor visibility hooks

---

## Contribution Areas

We need help with:

- Product management
- UX and accessibility
- Frontend/PWA development
- Backend development
- Nostr protocol integration
- Bitcoin/Lightning integration
- BTCPay Server integration
- Nostr Wallet Connect research
- Golf scoring logic
- Course data ingestion
- OpenStreetMap and open map integration
- QA and event-day testing
- Security review
- License review
- Documentation
- Sponsorship and ecosystem outreach

Good first issues should be clearly marked with `good-first-issue`.

---

## Definition of Done

For MVP issues, done means:

- The feature works in the intended user flow
- Acceptance criteria are met
- Relevant tests or manual test notes exist
- Accessibility basics are considered
- Security implications are reviewed where relevant
- License implications are reviewed where relevant
- Documentation is updated if behavior changes
- The feature can be demoed by a contributor who did not build it

---

## Guiding Principles

- Open source first
- Bitcoin only for monetary flows
- Nostr-native identity and public event layer
- Non-custodial wallet posture
- Real tournament usability over abstract protocol purity
- Mobile-first, PWA-first delivery
- Accessibility is not optional
- Data provenance matters
- Legal/compliance review before betting or prediction markets
- Build something people can actually use on event day

---

## Current Status

This project is in early MVP planning and repository formation.

The immediate priorities are:

1. Finalize repository governance files.
2. Import the initial issue backlog.
3. Validate labels, milestones, and issue templates.
4. Start Sprint 0 project foundation work.
5. Move from planning artifacts into working prototypes.

