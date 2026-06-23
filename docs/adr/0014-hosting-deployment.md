# ADR 0014: Use Railway or Render for Hosting and Deployment

## Status

Accepted

- **Date:** 2026-06-23
- **Decision owners:** sebrock
- **Reviewers:** sebrock

## Context

The backend and PWA require hosting, continuous deployment, database management, and monitoring. The project aims to minimize operational overhead while maintaining reliability and non-custodial principles.

Hosting choices impact:

- Time to first deployment
- Operational complexity (database backups, SSL, monitoring)
- Scaling capacity and cost
- Developer experience (CI/CD integration, environment management)
- Compliance and data residency requirements

## Decision

We will use **Railway.app or Render.com** for hosting and deployment.

**Recommended: Railway.app** for MVP because:

- Excellent GitHub integration (auto-deploy on push)
- Managed PostgreSQL included
- Simple environment variable management
- Built-in monitoring and logs
- Free tier generous for MVP

Additionally:

- **CI/CD**: GitHub Actions for test and lint checks before deployment
- **Branch Strategy**: main = production, staging = pre-prod testing
- **Database**: Managed PostgreSQL (Railway/Render managed)
- **SSL/HTTPS**: Automatic (Railway/Render handles)
- **CDN**: Railway/Render built-in
- **Monitoring**: Railway/Render logs + Sentry for error tracking (post-MVP)
- **Backups**: Railway/Render automatic daily backups

## Alternatives

- **Vercel**: Great for Next.js, complicates Express.js deployment
- **Heroku**: Excellent DX but expensive for production, less generous free tier
- **AWS (EC2/RDS)**: Full control, high operational complexity, not suitable for MVP
- **DigitalOcean App Platform**: Good alternative to Railway/Render, similar pricing
- **Self-hosted VPS**: Full control, requires DevOps expertise, not suitable for MVP
- **Google Cloud Run / AWS Lambda**: Serverless options, good for stateless APIs, less suitable for persistent database

## Trade-offs

**Pros**:

- Zero-ops database management (automatic backups, SSL, scaling)
- GitHub integration means `git push` → deployed
- Simple environment variables and secrets management
- Generous free tier for MVP phase
- Easy to scale vertically (add more resources) without infrastructure changes
- Built-in logging and monitoring
- High uptime SLA (99.9% for production plans)

**Cons**:

- Vendor lock-in (but infrastructure as code keeps costs portable)
- Limited by managed provider's feature set (negligible for MVP)
- Pricing scales with usage (manageable with traffic limits)
- Data residency in provider's data centers (may not align with future requirements)

## License Review

- **Railway**: Proprietary SaaS (data is portable, can migrate to self-hosted)
- **Render**: Proprietary SaaS (similar portability)
- **GitHub Actions**: Included with GitHub (free for public repos)
- No license concerns for open-source project

## Security Review

- Railway/Render handle SSL/TLS certificate management
- Environment variables stored securely (not in code)
- PostgreSQL password managed by provider
- Automatic security updates
- Network isolation between services
- Implement Content Security Policy (CSP) headers in Express.js
- Use `.env.example` (no secrets) for repository
- Store secrets in GitHub Secrets and Railway/Render environment
- Enable 2FA on Railway/Render accounts
- Audit logs in Railway/Render dashboards

## Rollback Plan

If Railway/Render becomes a blocker:

1. Migrate to DigitalOcean App Platform (similar API, easier transition)
2. Migrate to self-hosted (VPS + Docker) if scalability requires
3. Keep GitHub Actions for CI/CD (works with any provider)

## Implementation Plan

### Week 1: Initial Setup

- [ ] Create Railway.app project from GitHub repo
- [ ] Add postgres template to Railway project
- [ ] Connect GitHub repository for auto-deploy
- [ ] Set DATABASE_URL environment variable
- [ ] Deploy initial backend (Express + Prisma)
- [ ] Verify database connectivity

### Week 2: CI/CD & Monitoring

- [ ] Create GitHub Actions workflow for testing + linting
- [ ] Add Sentry for error tracking (optional for MVP)
- [ ] Configure staging environment for testing
- [ ] Document deployment process

### Week 3: Production Hardening

- [ ] Enable backups and test restore cycle
- [ ] Configure rate limiting and DDoS protection
- [ ] Add monitoring alerts for critical errors
- [ ] Document runbook for common issues

## Railway Project Structure

```
ride-or-die-scorecard/
├── services/
│   ├── backend/          # Express.js API
│   │   └── railway.json  # Railway config
│   └── frontend/         # React PWA
│       └── railway.json
├── .github/
│   └── workflows/
│       └── test.yml      # GitHub Actions
├── docker-compose.yml    # Local dev (optional)
└── README.md
```

## Deployment Environment Variables

```bash
# Backend
NODE_ENV=production
DATABASE_URL=postgresql://user:pass@host:5432/db
JWT_SECRET=<generated>
NOSTR_RELAY_URLS=wss://relay.damus.io,wss://relay.nostr.band
BTCPAY_SERVER_URL=https://btcpay.example.com
BTCPAY_API_KEY=<from BTCPay>

# Frontend (Railway detects and builds automatically)
VITE_API_BASE_URL=https://api.rideordie.example.com
VITE_NOSTR_RELAY_URLS=wss://relay.damus.io,wss://relay.nostr.band
```

## Monitoring & Alerts (Post-MVP)

- [ ] Error rate exceeds 1% → alert on Slack
- [ ] Database query > 1s → log and monitor
- [ ] Memory usage > 80% → alert
- [ ] API response time > 500ms → log slow endpoint
- [ ] Daily backup verification → Slack summary

## Validation

- [ ] Backend deployed to Railway, responds to HTTP requests
- [ ] Frontend PWA deployed to Railway, loads in browser
- [ ] Environment variables are set and accessible
- [ ] Database connection succeeds from deployed backend
- [ ] `git push main` triggers automatic test → deploy
- [ ] Logs are viewable in Railway dashboard
- [ ] Backups are automated (confirmed in Railway UI)
- [ ] SSL certificate is valid and auto-renewed

## Follow-up Decisions

- Should we separate backend and frontend into different Railway projects? (Recommended for cleaner separation)
- Should we use containers (Docker) or native buildpacks? (Native buildpacks simpler for MVP)
- What is the traffic/cost estimation for MVP load?
- Do we need a CDN in front of Railway? (Probably not for MVP)

## References

- [Railway.app Documentation](https://docs.railway.app/)
- [Render Documentation](https://render.com/docs)
- [GitHub Actions for CI/CD](https://github.com/features/actions)
- [Railway PostgreSQL Guide](https://docs.railway.app/databases/postgresql)
- [Express.js Deployment](https://expressjs.com/en/advanced/best-practice-performance.html)
