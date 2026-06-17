# Viteezy Web Frontend

Frontend repository for Viteezy on branch `new_web_frontend`.

For full operational details, see `TECHNICAL_HANDOVER.md`.

## Repository

- Remote: `https://github.com/nikunjgoyani5/viteezy-v2.git`
- Branch: `new_web_frontend`
- Stack: Next.js 16 + React 19 + TypeScript

## Local Setup

1. Install dependencies:

```bash
npm install
```

2. Set required environment variables:

```bash
NEXT_PUBLIC_API_BASE_URL=
NEXT_PUBLIC_API_QUIZ_URL=
```

3. Start development server:

```bash
npm run dev
```

Default local URL: `http://localhost:8080`.

## Build and Run

```bash
npm run build
npm run start
```

## Deployment Notes

- Dockerfile exists for standalone Next.js runtime (`Dockerfile`)
- Canonical deployment runbooks are maintained in `deployment_docs/` on branch `new_backend` (backend/admin/web docs centralized there by team decision)
- Build arguments expected by Docker build:
  - `NEXT_PUBLIC_API_BASE_URL`
  - `NEXT_PUBLIC_SERVER_URL`
  - `NEXT_PUBLIC_API_QUIZ_URL`
- No deployment script (`deploy.sh`) found in this branch
- No CI/CD workflow files found in this branch

