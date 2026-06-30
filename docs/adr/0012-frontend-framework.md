# ADR 0012: Use React 18 with TypeScript for PWA Frontend

## Status

Proposed

## Context

The PWA client (ADR-0003) must support Nostr identity signing, real-time score submission and attestation, offline scorekeeper workflows, and responsive mobile-first UI. The frontend should share the same language/tooling as the backend to reduce cognitive load.

Frontend framework choices impact:

- PWA capabilities and offline support
- Nostr library availability
- Service worker integration complexity
- Developer experience and hiring
- Build performance and bundle size

## Decision

We will use **React 18.x with TypeScript** as the PWA frontend framework.

Additionally:

- **Build Tool**: Vite (not webpack or Next.js) for fast development and production builds
- **UI Component Library**: shadcn/ui + Tamagui for accessible, composable components
- **State Management**: Redux Toolkit (or Zustand if simpler state model emerges)
- **Service Worker**: Workbox (via Vite PWA plugin) for offline and caching
- **HTTP Client**: axios or fetch (native)
- **Nostr Integration**: nostr-tools + custom React hooks

## Alternatives

- **Next.js**: Framework overhead, complicates offline/PWA strategy, introduces server coupling
- **Vue.js 3**: Excellent framework, but smaller Nostr ecosystem than React
- **Svelte**: Elegant, but fewer Bitcoin/Nostr integrations available
- **Solid.js**: Promising, immature, weak Nostr library support
- **Preact**: Lightweight, but reduces library compatibility

## Trade-offs

**Pros**:

- React has the largest Nostr/Bitcoin developer community
- TypeScript + React is well-understood, strong hiring pool
- Vite is exceptionally fast (10x faster dev builds than webpack)
- Workbox integration is mature and well-documented
- Redux Toolkit is battle-tested for complex offline/sync scenarios
- shadcn/ui provides accessible component primitives
- Hot Module Replacement (HMR) with Vite is excellent for rapid iteration

**Cons**:

- React ecosystem can be overwhelming (many choices for state, routing, UI)
- Bundle size requires careful splitting (tree-shaking, code splitting)
- Service worker complexity can grow quickly with offline features
- Virtual DOM overhead negligible for most use cases but worth monitoring

## License Review

- **React**: MIT, backed by Meta ✓
- **TypeScript**: Apache 2.0 ✓
- **Vite**: MIT, community-maintained ✓
- **Workbox**: Apache 2.0, backed by Google ✓
- **shadcn/ui**: MIT ✓
- **Redux Toolkit**: MIT ✓
- **nostr-tools**: MIT ✓
- All open-source and compatible with project license

## Security Review

- React has strong XSS protections (JSX escaping)
- TypeScript's type system prevents many client-side injection attacks
- Must NOT cache sensitive Nostr keys or session tokens in service worker
- Service worker must not cache authentication responses
- Use SameSite cookies and secure cookie flags
- Implement Content Security Policy (CSP) headers
- Validate all Nostr event signatures on the client before trusting them

## Rollback Plan

If React/Vite complexity becomes a blocker:

1. Migrate to Preact (drop-in replacement, smaller bundle)
2. Migrate to Vue.js (similar reactive model, good ecosystem)
3. Simplify state management (Zustand instead of Redux Toolkit)

## Implementation Plan

- Set up Vite project with React + TypeScript template
- Configure Workbox for offline support and precaching
- Create Redux store for Nostr identity, scores, attestations, offline queue
- Implement NIP-07 browser extension signing flow
- Add PWA manifest and splash screens
- Create responsive mobile-first UI with shadcn/ui
- Implement offline state sync when connectivity returns
- Add Vitest unit tests and React Testing Library integration tests

## Validation

- React component compilation succeeds with strict TypeScript
- App works on Chrome, Safari, Firefox, Edge (desktop and mobile)
- Service worker caches critical assets and serves offline
- Scorekeeper can submit scores while offline (saved to local queue)
- Offline changes sync when connectivity restored
- App is installable to home screen (PWA manifest valid)
- Bundle size < 300KB (gzipped)

## Follow-up Decisions

- Which routing library? (React Router v6 recommended, or TanStack Router for type-safe routes?)
- How is offline state merged with server state? (Last-write-wins, conflict resolution?)
- Should we use tRPC on the frontend for end-to-end type safety from API?
- Which UI components are highest priority for MVP? (Login, score form, attestation list)

## References

- [React Documentation](https://react.dev/)
- [Vite Documentation](https://vitejs.dev/)
- [Workbox Documentation](https://developers.google.com/web/tools/workbox/)
- [shadcn/ui](https://ui.shadcn.com/)
- [Redux Toolkit](https://redux-toolkit.js.org/)
- [nostr-tools GitHub](https://github.com/nbd-wtf/nostr-tools)
- [PWA Checklist](https://web.dev/pwa-checklist/)
