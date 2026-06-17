# Viteezy Admin Panel

Admin frontend repository for Viteezy on branch `new_admin`.

For operational and architecture details, see `TECHNICAL_HANDOVER.md`.

## Repository

- Remote: `https://github.com/nikunjgoyani5/viteezy-v2.git`
- Branch: `new_admin`
- Stack: Next.js 16 + React 19 + TypeScript + Redux Toolkit/RTK Query

## Local Setup

1. Install dependencies:

```bash
npm install
```

2. Configure environment variables:

```bash
NEXT_PUBLIC_API_BASE_URL=
NEXT_PUBLIC_LANDING_PREVIEW_URL=
```

3. Run development server:

```bash
npm run dev
```

Default local URL: `http://localhost:8081`.

## Build and Run

```bash
npm run build
npm run start
```

## Deployment Notes

- Docker runtime support exists via `Dockerfile` (standalone Next.js build)
- App scripts run on port `8081` (`npm run dev`, `npm run start`)
- Docker runtime image exposes port `3000`
- Branch-local deployment scripts/CI workflows are not present in this checkout
- Team runbooks are centralized in `deployment_docs/` on branch `new_backend` (not duplicated in every branch)
