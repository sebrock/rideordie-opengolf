# ADR 0021: Implement Service-Worker-Based Offline Scorekeeper Workflow

## Status

Proposed

## Context

Golf events happen on courses, often with poor or no cellular coverage. Scorekeepers must submit scores offline, then sync when connectivity is restored. PWA offline strategy (ADR-0003) requires deliberate design.

Offline strategy choices impact:

- Event usability (can scorekeeper work offline?)
- Data consistency (conflicts when offline queue syncs?)
- User experience (visible indication of sync state?)
- Operational load (retry logic, conflict resolution)

## Decision

We will implement **service-worker-based offline scorekeeper workflow** with the following capabilities:

**Offline Capabilities**:

- Submit scores while offline (saved to local IndexedDB)
- View submitted scores
- Edit scores before sync
- View local edit history

**Sync Strategy**:

- Automatic sync when connectivity returns
- Manual sync button for user control
- Last-write-wins conflict resolution (local changes override server if older)
- Exponential backoff for retry

**User Feedback**:

- Sync status indicator in UI
- Queued scores highlighted (not yet synced)
- Sync errors shown with retry button
- Estimated sync time

## Alternatives

- **Optimistic updates only**: Assume all requests succeed (loses offline data)
- **Server state as source of truth**: Reject local changes on conflict (user frustration)
- **Manual conflict resolution**: Ask user to choose (too much friction)
- **No offline support**: Users must wait for connectivity (unacceptable)

## Trade-offs

**Pros**:

- Scorekeeper can work offline reliably
- Last-write-wins is deterministic (no user prompts)
- Service worker is transparent (zero learning curve)
- Sync happens automatically (no manual steps)
- Works even if user closes tab/browser

**Cons**:

- Last-write-wins can overwrite server changes (mitigated by audit trail)
- Service worker complexity and debugging challenges
- Cache invalidation can be tricky
- iOS PWA service workers are limited (still functional but less capable)

## License Review

- **Workbox**: Apache 2.0, open-source ✓
- **IndexedDB**: Browser standard, no licensing concerns

## Security Review

- Do NOT cache authentication tokens or session data
- Cache only is only safe data (scores, user profiles)
- Invalidate cache on logout
- Use secure headers (Cache-Control: no-store)
- Service worker must be served over HTTPS
- Validate all synced data on server (client could be tampered)

## Rollback Plan

If offline sync proves problematic:

1. Disable offline scorekeeper (require online)
2. Fall back to read-only offline mode (view only, no submit)
3. Implement simple localStorage fallback (no service worker)

## Implementation Plan

### Phase 1: Service Worker Setup

- [ ] Create service worker with Workbox
- [ ] Configure cache strategy (precache critical assets)
- [ ] Implement offline fallback page

### Phase 2: Offline Score Queue

- [ ] Create IndexedDB schema for queued scores
- [ ] Implement offline submit handler (save to IndexedDB)
- [ ] Create queue management UI (view pending syncs)

### Phase 3: Sync Engine

- [ ] Implement sync worker (retry loop with backoff)
- [ ] Handle conflict resolution (last-write-wins)
- [ ] Add sync status indicator to UI

### Phase 4: User Experience

- [ ] Add sync progress indicator
- [ ] Show queued items in list (different styling)
- [ ] Create manual sync button
- [ ] Display sync error messages

## Service Worker Cache Strategy

```typescript
import { precacheAndRoute } from 'workbox-precaching'
import { registerRoute } from 'workbox-routing'
import { CacheFirst, NetworkFirst, StaleWhileRevalidate } from 'workbox-strategies'

// Precache shell assets (critical for offline)
precacheAndRoute(self.__WB_MANIFEST)

// API calls: try network first, fall back to cache
registerRoute(
  ({ url }) => url.pathname.startsWith('/api/'),
  new NetworkFirst({
    cacheName: 'api-cache',
    plugins: [
      new ExpirationPlugin({
        maxEntries: 50,
        maxAgeSeconds: 5 * 60, // 5 minutes
      }),
    ],
  })
)

// Static assets: cache first
registerRoute(
  ({ request }) => request.destination === 'image' ||
                    request.destination === 'font',
  new CacheFirst({
    cacheName: 'static-assets',
    plugins: [
      new ExpirationPlugin({
        maxEntries: 100,
        maxAgeSeconds: 30 * 24 * 60 * 60, // 30 days
      }),
    ],
  })
)

// HTML: stale while revalidate
registerRoute(
  ({ request }) => request.mode === 'navigate',
  new StaleWhileRevalidate({
    cacheName: 'html-cache',
  })
)
```

## Offline Queue Model

```typescript
// IndexedDB schema
interface OfflineScore {
  id: string              // UUID
  scoreId?: string        // Server ID once synced
  createdAt: number       // Timestamp when created locally
  updatedAt: number       // Last local edit
  
  // Score data
  eventId: string
  courseId: string
  scoreValue: number
  payload: any
  
  // Sync state
  status: 'PENDING' | 'SYNCING' | 'SYNCED' | 'FAILED'
  error?: string
  retryCount: number
  lastRetryAt?: number
}

// IndexedDB store
const dbName = 'ride-or-die'
const storeName = 'offline-scores'

function initDb(): Promise<IDBDatabase> {
  return new Promise((resolve, reject) => {
    const req = indexedDB.open(dbName, 1)
    req.onupgradeneeded = (e) => {
      const db = (e.target as IDBOpenDBRequest).result
      if (!db.objectStoreNames.contains(storeName)) {
        db.createObjectStore(storeName, { keyPath: 'id' })
      }
    }
    req.onsuccess = () => resolve((req.target as IDBOpenDBRequest).result)
    req.onerror = () => reject(req.error)
  })
}

async function saveOfflineScore(score: OfflineScore) {
  const db = await initDb()
  return new Promise((resolve, reject) => {
    const tx = db.transaction(storeName, 'readwrite')
    const store = tx.objectStore(storeName)
    const req = store.put(score)
    req.onsuccess = () => resolve(req.result)
    req.onerror = () => reject(req.error)
  })
}
```

## Offline Submit Handler

```typescript
// In React component
async function submitScoreOffline(score: ScorePayload) {
  const offlineScore: OfflineScore = {
    id: uuid(),
    createdAt: Date.now(),
    updatedAt: Date.now(),
    ...score,
    status: 'PENDING',
    retryCount: 0,
  }

  // Save to IndexedDB
  await saveOfflineScore(offlineScore)

  // Add to Redux store (UI updates)
  dispatch(addQueuedScore(offlineScore))

  // Trigger sync if online
  if (navigator.onLine) {
    await syncOfflineScores()
  }

  return offlineScore
}
```

## Sync Engine

```typescript
async function syncOfflineScores() {
  const db = await initDb()
  
  // Get all pending scores
  const pendingScores = await getPendingScores(db)
  
  for (const offlineScore of pendingScores) {
    try {
      // Attempt to submit to server
      const response = await fetch('/api/scores', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(offlineScore),
      })

      if (response.ok) {
        const serverScore = await response.json()
        
        // Update local with server ID and mark synced
        await updateOfflineScore(db, offlineScore.id, {
          scoreId: serverScore.id,
          status: 'SYNCED',
          retryCount: 0,
        })

        dispatch(syncScore(offlineScore.id))
      } else if (response.status === 409) {
        // Conflict: server has newer version
        const serverVersion = await response.json()
        
        // Last-write-wins: if local is newer, keep local
        if (offlineScore.updatedAt > serverVersion.updatedAt) {
          // Continue retrying
          await incrementRetry(db, offlineScore.id)
        } else {
          // Server wins, merge and mark synced
          await mergeScore(db, offlineScore.id, serverVersion)
        }
      } else {
        throw new Error(`HTTP ${response.status}`)
      }
    } catch (err) {
      // Handle retry with exponential backoff
      const retryCount = offlineScore.retryCount + 1
      const backoffMs = Math.min(1000 * Math.pow(2, retryCount), 30000)
      
      await updateOfflineScore(db, offlineScore.id, {
        status: 'FAILED',
        error: err.message,
        retryCount,
        lastRetryAt: Date.now() + backoffMs,
      })

      dispatch(syncFailed(offlineScore.id, err.message))
    }
  }
}

// Listen for online event and sync
window.addEventListener('online', async () => {
  await syncOfflineScores()
})

// Periodic sync (every 30 seconds if offline, or when tab becomes visible)
setInterval(() => {
  if (navigator.onLine) {
    syncOfflineScores()
  }
}, 30000)

document.addEventListener('visibilitychange', () => {
  if (!document.hidden && navigator.onLine) {
    syncOfflineScores()
  }
})
```

## Sync Status UI Component

```typescript
function SyncStatusIndicator() {
  const [syncState, setSyncState] = useState<'online' | 'offline' | 'syncing'>('online')
  const queuedScores = useSelector(state => state.offlineQueue.pending)

  useEffect(() => {
    window.addEventListener('online', () => setSyncState('syncing'))
    window.addEventListener('offline', () => setSyncState('offline'))
  }, [])

  if (syncState === 'offline') {
    return (
      <div className="sync-indicator offline">
        <Icon>signal_cellular_no_sim</Icon>
        <span>Offline - Changes will sync when online</span>
      </div>
    )
  }

  if (syncState === 'syncing') {
    return (
      <div className="sync-indicator syncing">
        <Spinner />
        <span>Syncing {queuedScores.length} score(s)...</span>
        <button onClick={() => syncOfflineScores()}>Sync Now</button>
      </div>
    )
  }

  return null
}
```

## Queued Score UI

```typescript
function ScoreListItem({ score }: { score: Score }) {
  const isQueued = score.status === 'PENDING' || score.status === 'SYNCING'
  const hasSyncError = score.status === 'FAILED'

  return (
    <div className={`score-item ${isQueued ? 'queued' : ''}`}>
      <div className="score-value">{score.scoreValue}</div>
      <div className="score-course">{score.courseName}</div>
      
      {isQueued && (
        <Badge status="warning">Not yet synced</Badge>
      )}
      
      {hasSyncError && (
        <div className="error">
          <span>{score.error}</span>
          <button onClick={() => syncOfflineScores()}>Retry</button>
        </div>
      )}
    </div>
  )
}
```

## Validation

- [ ] Score can be submitted while offline
- [ ] Offline scores saved to IndexedDB
- [ ] Service worker precaches critical assets
- [ ] Sync triggered when connectivity returns
- [ ] Queued scores synced automatically
- [ ] Sync status visible to user
- [ ] Manual sync button works
- [ ] Conflict resolution (last-write-wins) works
- [ ] Sync retry with backoff works
- [ ] iOS PWA offline mode works

## Follow-up Decisions

- Should we implement collaborative conflict resolution post-MVP?
- Should we add rich editing (photos, witness signatures) for offline scores?
- Should we support score deletion while offline?
- Should we implement full offline event calendar view?

## References

- ADR-0003: PWA Client Strategy
- [Workbox Documentation](https://developers.google.com/web/tools/workbox/)
- [IndexedDB API](https://developer.mozilla.org/en-US/docs/Web/API/IndexedDB_API)
- [Service Worker API](https://developer.mozilla.org/en-US/docs/Web/API/Service_Worker_API)
