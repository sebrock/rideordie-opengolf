# ADR 0003: Use a Progressive Web App as the Primary Client

## Status

Accepted

- **Date:** 2026-06-22
- **Decision owners:** sebrock
- **Reviewers:** sebrock

## Context

Ride or Die Scorecard should work across phones, tablets, and desktop devices without app-store dependency. The event environment may include mixed devices, unstable connectivity, and users who need quick access on-site.

## Decision

We will build the MVP as a Progressive Web App.

## Alternatives

- Native iOS and Android apps.
- Desktop-first web app only.
- Cross-platform native wrapper.
- Messaging-bot-first interface.

## Trade-offs

- PWA supports broad device access and fast iteration.
- iOS PWA capabilities can lag behind native apps.
- Offline behavior must be deliberately designed.
- Push notification support may vary by device and browser.

## License Review

- Review licenses for PWA framework, UI libraries, service worker tooling, and icon/font assets.
- Prefer open-source frameworks and avoid proprietary UI kits.

## Security Review

- Secure service-worker caching rules.
- Avoid caching sensitive wallet/session data.
- Use HTTPS only.
- Define session handling for shared devices.

## Rollback Plan

If PWA limitations block event operations, create a thin native wrapper or dedicated scorekeeper web mode as a fallback without changing backend APIs.

## Implementation Plan

- Define responsive layout targets.
- Add installable PWA manifest.
- Add offline/error state strategy.
- Add scorekeeper-first mobile flows.

## Validation

- Works on current Chrome, Safari, Firefox, Edge mobile/desktop.
- Scorekeeper can submit scores on a phone.
- Users can install the app to home screen.

## Follow-up Decisions

- Which browsers/devices are officially supported?
- Which features must work offline?
- Are push notifications required for MVP?

## References

- Project Foundation Document
- Accessibility guidelines
