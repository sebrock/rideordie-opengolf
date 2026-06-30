# ADR 0022: Use Workbox for Service Worker Asset Precaching and Cache Management

## Status

Proposed

## Context

Service worker caching strategy (ADR-0021) requires careful management to balance offline availability with freshness. Workbox is a library that simplifies service worker development with battle-tested patterns.

Cache management choices impact:

- App startup time (precaching vs lazy loading)
- Asset freshness (cache staleness)
- Disk usage (storage quota management)
- Developer experience (configuration complexity)

## Decision

We will use **Workbox for service worker asset precaching and cache management**.

Additionally:

- **Precaching Strategy**: Critical shell assets only (HTML, core JS, CSS)
- **API Caching**: NetworkFirst (try server, fall back to cache)
- **Asset Caching**: StaleWhileRevalidate (serve cached, update in background)
- **Cache Expiration**: Per-resource TTL + size limits
- **Version Management**: Automatic via build hash

## Alternatives

- **Manual service worker**: Full control, very complex, high maintenance
- **Offline.js**: Simpler, less flexible, weaker ecosystem
- **No service worker**: No offline support (unacceptable for scorekeeper)

## Trade-offs

**Pros**:

- Workbox handles cache versioning automatically (build hash)
- Precaching strategy is simple configuration
- Excellent error handling and fallbacks
- Mature library with strong community
- Works with Vite build system

**Cons**:

- Adds ~18KB gzipped (manageable)
- Service worker debugging still challenging
- Cache invalidation can be tricky

## License Review

- **Workbox**: Apache 2.0, backed by Google ✓
- Open-source and permissive licensing

## Security Review

- Workbox respects HTTPS requirement (no caching over HTTP)
- Precache only safe assets (no auth tokens, no user data)
- NetworkFirst for API ensures fresh data when online
- Cache cleanup on service worker update (automatic)
- CSP headers should allow service worker

## Rollback Plan

If Workbox causes issues:

1. Fall back to manual service worker (same cache strategies)
2. Disable service worker entirely (loose offline functionality)

## Implementation Plan

### Phase 1: Workbox Integration

- [ ] Install @vite-pwa/vite plugin
- [ ] Configure precache manifest
- [ ] Enable automatic service worker generation

### Phase 2: Cache Strategies

- [ ] Configure NetworkFirst for API routes
- [ ] Configure CacheFirst for static assets
- [ ] Configure StaleWhileRevalidate for HTML
- [ ] Set cache expiration policies

### Phase 3: Testing

- [ ] Test precache loading
- [ ] Test offline fallback
- [ ] Test cache invalidation on update
- [ ] Test iOS PWA caching

## Vite PWA Configuration

```typescript
// vite.config.ts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { VitePWA } from 'vite-plugin-pwa'

export default defineConfig({
  plugins: [
    react(),
    VitePWA({
      registerType: 'autoUpdate',
      
      // Precache strategy
      workbox: {
        // Only precache critical assets
        globPatterns: [
          '**/*.{js,css,html}',
          '**/fonts/*.woff2',
        ],
        
        // Don't precache
        globIgnores: [
          '**/node_modules/**/*',
          'dist/config/**/*',
        ],
        
        // Cache strategies
        runtimeCaching: [
          // API calls: network first
          {
            urlPattern: /^https:\/\/.*\/api\/.*/i,
            handler: 'NetworkFirst',
            options: {
              cacheName: 'api-cache',
              networkTimeoutSeconds: 5,
              expiration: {
                maxEntries: 50,
                maxAgeSeconds: 300, // 5 minutes
              },
            },
          },
          
          // Images: cache first
          {
            urlPattern: /^https:\/\/.*\.(jpg|jpeg|png|gif|webp|svg)$/i,
            handler: 'CacheFirst',
            options: {
              cacheName: 'image-cache',
              expiration: {
                maxEntries: 100,
                maxAgeSeconds: 30 * 24 * 60 * 60, // 30 days
              },
            },
          },
          
          // Fonts: cache first with long TTL
          {
            urlPattern: /^https:\/\/.*\.(woff|woff2|ttf|eot)$/i,
            handler: 'CacheFirst',
            options: {
              cacheName: 'font-cache',
              expiration: {
                maxAgeSeconds: 60 * 60 * 24 * 365, // 1 year
              },
            },
          },
          
          // HTML: stale while revalidate
          {
            urlPattern: /\.html$/,
            handler: 'StaleWhileRevalidate',
            options: {
              cacheName: 'html-cache',
              expiration: {
                maxAgeSeconds: 60 * 60 * 24, // 1 day
              },
            },
          },
        ],
      },
      
      // PWA manifest
      manifest: {
        name: 'Ride or Die Scorecard',
        short_name: 'ROD Scorecard',
        description: 'Bitcoin-native golf scoring platform',
        theme_color: '#ffffff',
        background_color: '#ffffff',
        display: 'standalone',
        start_url: '/',
        scope: '/',
        icons: [
          {
            src: '/icon-192.png',
            sizes: '192x192',
            type: 'image/png',
            purpose: 'any maskable',
          },
          {
            src: '/icon-512.png',
            sizes: '512x512',
            type: 'image/png',
            purpose: 'any maskable',
          },
        ],
      },
    }),
  ],
})
```

## Service Worker Lifecycle Handling

```typescript
// In React component
import { useRegisterSW } from 'virtual:pwa-register/react'

function App() {
  const {
    offlineReady: [offlineReady, setOfflineReady],
    needRefresh: [needRefresh, setNeedRefresh],
    updateServiceWorker,
  } = useRegisterSW({
    onRegistered(r) {
      console.log('SW Registered:', r)
    },
    onRegisterError(error) {
      console.error('SW registration failed:', error)
    },
  })

  return (
    <div>
      {offlineReady && (
        <UpdatePrompt
          title="App ready for offline use"
          message="This application is now available offline"
          onDismiss={() => setOfflineReady(false)}
        />
      )}

      {needRefresh && (
        <UpdatePrompt
          title="New version available"
          message="A new version of the app is ready. Reload to update."
          onRefresh={() => updateServiceWorker(true)}
          onDismiss={() => setNeedRefresh(false)}
        />
      )}

      {/* App content */}
    </div>
  )
}
```

## Cache Versioning Strategy

Workbox automatically handles versioning via build hash:

```typescript
// Build process creates:
// dist/sw.js          (has hash in import)
// dist/manifest.xxxx.js (precache manifest)

// Service worker sees build hash and invalidates old caches automatically
// No manual cache busting required
```

## Cache Size Management

```typescript
// Workbox automatically respects browser storage quota
// Typical limits:
// - Chrome: ~50% of available disk
// - Safari: ~50MB on iOS, unlimited on macOS
// - Firefox: ~10% of available disk

// Per cache size limits (from config):
// - api-cache: 50 entries, 5 minutes old
// - image-cache: 100 entries, 30 days old
// - font-cache: unlimited, 1 year old

// Old caches cleaned up on service worker activation
```

## Testing Cache Strategy

```typescript
// Test suite
describe('Service Worker Caching', () => {
  it('should precache critical assets', async () => {
    const cache = await caches.open('precache-v1')
    const keys = await cache.keys()
    expect(keys.length).toBeGreaterThan(0)
  })

  it('should use NetworkFirst for API', async () => {
    // Mock network failure
    // Verify cache is used as fallback
  })

  it('should update cache in background', async () => {
    // Trigger StaleWhileRevalidate
    // Verify old content served immediately
    // Verify new content cached for next load
  })
})
```

## iOS PWA Specific Handling

```typescript
// iOS PWA limitations:
// - Service workers have limited lifetime in background
// - Cache may be cleared on low disk space
// - No background sync or push notifications

// Mitigation:
// - Use NetworkFirst for critical data
// - Precache essential assets
// - Implement manual sync button
// - Show cache status indicator

function checkIOSCache() {
  const isIOS = /iPad|iPhone|iPod/.test(navigator.userAgent)
  
  if (isIOS) {
    // Warn user about cache limitations
    console.warn('iOS PWA caching has limitations')
    
    // More aggressive cache updates
    setInterval(() => {
      updateServiceWorker()
    }, 60 * 60 * 1000) // Every hour
  }
}
```

## Debugging Cache Issues

```typescript
// Clear all caches
async function clearAllCaches() {
  const names = await caches.keys()
  await Promise.all(names.map(name => caches.delete(name)))
  console.log('All caches cleared')
}

// View all cached items
async function listCached(cacheName: string) {
  const cache = await caches.open(cacheName)
  const requests = await cache.keys()
  console.log(`${cacheName}:`, requests.map(r => r.url))
}

// Check cache size (approximate)
async function estimateCacheSize() {
  const names = await caches.keys()
  let totalSize = 0
  
  for (const name of names) {
    const cache = await caches.open(name)
    const requests = await cache.keys()
    
    for (const request of requests) {
      const response = await cache.match(request)
      if (response && response.blob) {
        const blob = await response.blob()
        totalSize += blob.size
      }
    }
  }
  
  console.log(`Total cache size: ${(totalSize / 1024 / 1024).toFixed(2)}MB`)
}
```

## Validation

- [ ] Service worker installs successfully
- [ ] Precache manifest contains critical assets
- [ ] App works offline (API calls cached)
- [ ] NetworkFirst fetches new data when online
- [ ] CacheFirst uses latest static assets
- [ ] Cache clears on service worker update
- [ ] Storage quota is not exceeded
- [ ] iOS PWA caching works

## Follow-up Decisions

- Should we implement background sync for offline queue? (Post-MVP)
- Should we allow user to manually clear cache? (Yes, post-MVP)
- Should we implement smart cache eviction (ML-based)? (Probably not)

## References

- ADR-0021: PWA Offline Strategy
- [Workbox Documentation](https://developers.google.com/web/tools/workbox/)
- [Vite PWA Plugin](https://vite-pwa-org.netlify.app/)
- [Service Worker API](https://developer.mozilla.org/en-US/docs/Web/API/Service_Worker_API)
- [Cache Storage API](https://developer.mozilla.org/en-US/docs/Web/API/CacheStorage)
