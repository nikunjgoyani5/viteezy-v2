# Technical Handover - Viteezy Web Frontend

Prepared from repository evidence in `viteezy-v2` on branch `new_web_frontend`.

Cross-branch note: deployment runbooks for web frontend, admin, and backend are intentionally centralized under `deployment_docs/` on branch `new_backend` (not duplicated in every branch).

Evidence policy used:
- Verified from repository: explicit in source/config/scripts/files in this checkout
- Inferred from code: derived from implementation behavior
- Not Found in Repository: no verifiable evidence in this checkout

---

# Project Overview

## Purpose of the application

- Verified from repository: Next.js web frontend for Viteezy ecommerce flows (catalog, quiz UI, cart, checkout, account, blog, FAQ, static pages).
- Verified from repository: Integrates with backend APIs via RTK Query using environment-provided base URLs.

## Main user types

- Verified from repository: End users/customers (quiz, product browsing, checkout, account).
- Verified from repository: Authenticated users (orders, addresses, wishlist, profile, subscription-related screens).

## Major modules/features

- Verified from repository:
  - Authentication UI and flows
  - Product listing/details and cart
  - Checkout and order confirmation screens
  - Quiz chat UI and recommendation display
  - Blog, FAQ, static content pages
  - Multi-language UI with `next-intl`

## User journey (handover-friendly view)

- Inferred from code:
  1. User lands on home page and can browse content/products.
  2. User can start quiz flow (`/quiz`) and continue in session route (`/quiz/[id]`).
  3. Recommended or browsed products are added to cart/sidebar.
  4. Checkout flow completes through backend-driven order/payment APIs.
  5. Confirmation/failed routes show payment outcome.

## Main routes

- Verified from repository (from `src/app/**/page.tsx`):
  - `/`, `/products`, `/products/[id]`
  - `/quiz`, `/quiz/[id]`
  - `/checkout`, `/orderConfirmed`, `/orderConfirmed/success`, `/orderConfirmed/failed`
  - `/account`, `/settings`, `/settings/subscription/[id]`
  - `/blog`, `/blog/[id]`, `/faq`, `/faq/[slug]`, `/faq/[slug]/[id]`
  - `/membership`, `/membership/payment`
  - `/contactUs`, `/aboutUs`, `/ourTeam`, `/charity`, `/coming-soon`
  - Auth routes: `/login`, `/createAccount`, `/forgotPassword`, `/resetPassword`, `/verify-email`, `/changePassword`
  - CMS/static route: `/static-pages/[slug]`

---

# Tech Stack

| Layer | Stack | Evidence |
|-------|-------|----------|
| Frontend framework | Next.js 16 (App Router), React 19, TypeScript | `package.json`, `src/app/` |
| State and API | Redux Toolkit + RTK Query | `src/store/`, `src/store/api/` |
| Styling | Tailwind CSS 4 | `package.json`, `tailwind.config.ts`, `postcss.config.mjs` |
| i18n | `next-intl` | `next.config.ts`, `src/i18n/` |
| Auth SDKs | Firebase client SDK | `package.json`, `src/lib/firebase.ts` |
| Containerization | Docker multi-stage build for frontend | `Dockerfile` |
| CI/CD | Not Found in Repository | No `.github/workflows` in this checkout |

---

# High-Level Architecture

## Application flow

- Verified from repository:
  1. Next.js App Router renders pages from `src/app`.
  2. Client-side state and API access are provided through Redux store + RTK Query.
  3. Main API requests use `NEXT_PUBLIC_API_BASE_URL`.
  4. Quiz API requests use `NEXT_PUBLIC_API_QUIZ_URL`.
  5. Auth tokens are read from `localStorage` and attached on protected requests.

## Key services

- Verified from repository:
  - `baseApi` with token handling and refresh logic (`src/store/api/baseApi.ts`)
  - `quizApi` with session/chat/recommendation endpoints (`src/store/api/quizApi.ts`)
  - Locale handling (`src/i18n/config.ts`, `src/lib/services/locale.ts`, `src/lib/services/language.ts`)
  - Root layout providers and wrappers (`src/app/layout.tsx`) for i18n, Redux, maintenance gate, cart/subscription sidebars, and scroll/animation wrappers

## Architecture notes

- Inferred from code:
  - Frontend is API-first and depends on backend contracts for business workflows.
  - `NEXT_PUBLIC_*` values are expected at build/runtime depending on deployment mode.

---

# Repository Structure

| Path | Purpose |
|------|---------|
| `src/app/` | Next.js routes and layouts |
| `src/components/` | UI and feature components |
| `src/store/` | Redux store setup and API services |
| `src/store/api/` | RTK Query endpoint modules and API types |
| `src/lib/` | Helpers, Firebase config, language/locale services |
| `messages/` | Translation JSON files |
| `public/` | Static assets |
| `Dockerfile` | Container build/runtime definition for frontend |

---

# Environment Configuration

## Environment files used

- Verified from repository:
  - `.env*` patterns are ignored (`.gitignore`)
  - Main API base URL uses `NEXT_PUBLIC_API_BASE_URL` (`src/store/api/baseApi.ts`)
  - Quiz API base URL uses `NEXT_PUBLIC_API_QUIZ_URL` (`src/store/api/quizApi.ts`)
  - Docker build supports `NEXT_PUBLIC_SERVER_URL` in addition to the two API URLs (`Dockerfile`)

## Required environment variables

| Variable | Purpose | Status |
|----------|---------|--------|
| `NEXT_PUBLIC_API_BASE_URL` | Base URL for primary backend API | Verified from repository |
| `NEXT_PUBLIC_API_QUIZ_URL` | Base URL for quiz/chat API | Verified from repository |
| `NEXT_PUBLIC_SERVER_URL` | Public server URL injected during Docker build | Verified from repository |

Do not commit secret values in `.env` files.

---

# Local Development Setup

## Commands to run

| Command | Purpose |
|---------|---------|
| `npm run dev` | Run local development server on port 8080 |
| `npm run build` | Create production build |
| `npm run start` | Start production server on port 8080 |
| `npm run lint` | Run ESLint |

---

# Deployment Process

| Topic | Status | Notes |
|-------|--------|-------|
| Deployment script (`deploy.sh`) | Not Found in Repository | No deploy shell script in this branch |
| Central deployment runbooks | Partial | Maintained in `deployment_docs/` on branch `new_backend`; not present in this checkout branch |
| Docker deployment support | Verified from repository | Multi-stage Dockerfile builds Next standalone output |
| Container runtime port | Verified from repository | Docker runtime exposes port `3000` (`Dockerfile`) |
| App runtime port via npm scripts | Verified from repository | `dev` and `start` use `-p 8080` (`package.json`) |
| CI/CD workflows | Not Found in Repository | No workflow files in this checkout |
| Hosting provider details | Not Found in Repository | No server/vendor metadata in this branch |
| Reverse proxy setup (Nginx/Caddy) | Not Found in Repository | No config in this checkout |
| Environment matrix (dev/stage/prod) | Partial | Documented in `deployment_docs/Environments_Matrix.docx` on `new_backend`; file not present in this checkout |

## Docker behavior (`Dockerfile`)

- Verified from repository:
  - Builder image: `node:20-alpine`
  - Uses `pnpm` via corepack and installs with frozen lockfile
  - Runs `pnpm build`
  - Runtime image: `node:20-alpine`
  - Copies `.next/standalone`, `.next/static`, and `public`
  - Starts app with `node server.js`

Operational implication (inferred from code):
- Build-time `NEXT_PUBLIC_*` values will be embedded in frontend assets and should match target environment endpoints.

---

# External Integrations

| Integration | Purpose | Evidence |
|------------|---------|----------|
| Firebase | Social auth/client services | `src/lib/firebase.ts`, `package.json` |
| Klaviyo script | Marketing/onsite tracking script integration | `src/components/KlaviyoScript.tsx`, `src/app/layout.tsx` |
| CookieYes script | Cookie consent script loading in root layout | `src/app/layout.tsx` |
| Backend API | Auth, catalog, cart, checkout, content, account data | `src/store/api/*.ts` |
| Quiz API | Session/chat/recommendation flow | `src/store/api/quizApi.ts` |

Payment provider credentials and execution are backend-side; direct frontend secrets are not stored here.

---

# Critical Business Logic

## Session/auth handling

- Verified from repository:
  - Access/refresh tokens are read from `localStorage`.
  - Base API attempts token refresh on `401` and redirects to `/login` on session expiry.

## Quiz flow integration

- Verified from repository:
  - Frontend creates quiz sessions, posts chat messages, reads history, and fetches recommendations.
  - Recommendation request is triggered when quiz completion conditions are met in API responses.

## Internationalization

- Verified from repository:
  - Configured locales: `en`, `nl`, `de`, `fr`, `es`.
  - Default locale: `en`.

---

# Known Issues / Technical Debt

| Item | Evidence |
|------|----------|
| No deployment automation in branch | No `deploy.sh` and no CI workflow files |
| Runtime port mismatch possibility | Dockerfile exposes `3000`, while npm scripts run on `8080` |
| Debug logging in quiz API flows | `console.log` statements present in `src/store/api/quizApi.ts` |

---

# Operational Notes

| Topic | Status | Detail |
|-------|--------|--------|
| Branching strategy | Partial | `main`, `new_backend`, `new_web_frontend` exist; formal strategy not documented |
| Release process | Partial | Centralized deployment SOP exists on `new_backend` (`deployment_docs/`), but not present in this branch checkout |
| Feature flags | Partial | Behavior depends on environment variables and backend responses; no dedicated feature-flag framework found |
| Required startup order | Verified from repository | Frontend requires reachable backend API URLs for normal flows |
| Backup/restore procedures | Not Found in Repository | |

---

# Infrastructure Ownership

| Asset | Status | Detail |
|-------|--------|--------|
| Repository hosting | Verified from repository | `https://github.com/nikunjgoyani5/viteezy-v2.git` |
| Application hosting | Not Found in Repository | No host/server details in this branch |
| DNS/CDN providers | Not Found in Repository | |
| Backend service ownership | Partial | External backend required, but ownership/deployment not documented here |

---

# Handover Checklist

| Item | Status |
|------|--------|
| Source code available | Verified |
| Deployment process documented | Partial |
| Environment variables documented | Verified |
| Integrations documented | Verified |
| Known issues documented | Verified |
| Infrastructure documented | Partial |

