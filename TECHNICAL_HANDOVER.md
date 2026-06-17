# Technical Handover - Viteezy Admin Panel

Prepared from repository evidence in `viteezy-v2` on branch `new_admin`.

Cross-branch note: deployment runbooks for web frontend, admin, and backend are centralized in `deployment_docs/` on branch `new_backend` and are intentionally not duplicated in every branch.

Evidence policy used:
- Verified from repository: explicit in source/config/scripts/files in this checkout
- Inferred from code: derived from implementation behavior
- Not Found in Repository: no verifiable evidence in this checkout

---

# Project Overview

## Purpose of the application

- Verified from repository: Admin dashboard frontend for managing Viteezy platform entities such as users, products, categories, coupons, orders, subscriptions, blogs, FAQs, static pages, banners, testimonials, membership, and settings.
- Verified from repository: Next.js App Router application with protected admin routes and centralized API layer.

## Main user types

- Verified from repository: Admin users/operators accessing `/admin/*` modules.
- Inferred from code: Content/operations managers using domain-specific screens (CMS, products, orders, subscriptions, marketing content).

## Major modules/features

- Verified from repository:
  - Dashboard overview
  - User management
  - Product/category/ingredient management
  - Coupon management
  - Order and subscription management
  - CMS management (FAQs, testimonials, blog/category, static pages)
  - Header banners, membership plans, landing-page/admin content modules
  - General settings and coming-soon controls

## User journey (admin workflow)

- Inferred from code:
  1. Admin authenticates on `/login`.
  2. Middleware permits protected routes when `accessToken` cookie exists.
  3. Admin lands on `/admin/dashboard` and navigates modules via sidebar.
  4. CRUD actions are performed through RTK Query endpoints under `/admin/*` APIs.
  5. Token refresh is attempted automatically on `401` responses.

---

# Tech Stack

| Layer | Stack | Evidence |
|-------|-------|----------|
| Frontend framework | Next.js 16, React 19, TypeScript | `package.json` |
| State and API | Redux Toolkit + RTK Query | `src/store/`, `src/store/api/` |
| Styling/UI | Tailwind CSS 4, Radix UI | `package.json`, `components.json` |
| Forms/validation | `react-hook-form`, `yup` | `package.json` |
| Charts/tables | `chart.js`, `react-chartjs-2`, TanStack table | `package.json` |
| Containerization | Docker multi-stage standalone build | `Dockerfile`, `next.config.ts` |
| CI/CD | Not Found in Repository | No `.github/workflows` in this checkout |

---

# High-Level Architecture

## Application flow

- Verified from repository:
  1. Root route redirects to admin dashboard route constants.
  2. Middleware protects `/admin` and related routes using cookie token checks.
  3. Root layout wraps app with Redux `StoreProvider` and toaster notifications.
  4. Admin modules call backend through `baseApi` at `NEXT_PUBLIC_API_BASE_URL`.
  5. `baseQueryWithAuth` handles access token usage and refresh-token retry flow.

## Key services

- Verified from repository:
  - `src/middleware.ts` route protection and auth-route redirection
  - `src/lib/token.ts` token persistence in cookie + localStorage
  - `src/store/api/baseApi.ts` shared auth-aware query and tag registry
  - `src/constants/routes.ts` canonical route mapping for admin modules

## Architecture notes

- Inferred from code:
  - App is API-driven and depends on backend admin contracts for all core business actions.
  - Cookies are used in middleware for route gating; client also stores tokens in localStorage for API calls.

---

# Repository Structure

| Path | Purpose |
|------|---------|
| `src/app/` | Next.js App Router pages including auth and `/admin/*` modules |
| `src/components/` | Reusable admin UI and feature modules |
| `src/store/` | Redux store and provider |
| `src/store/api/` | RTK Query APIs and typed request/response models |
| `src/constants/` | Routes and static app constants |
| `src/data/` | Sidebar/menu data and static admin data config |
| `src/lib/` | Token utilities and shared helpers |
| `public/` | Static assets/icons/logos |
| `Dockerfile` | Container build/runtime definition |
| `docs/examples/` | Local component/table example files |

---

# Main Routes

- Verified from repository (`src/app/**/page.tsx`):
  - Auth: `/login`, `/forgotPassword`, `/resetPassword`
  - Root redirect: `/` -> dashboard route
  - Admin base: `/admin`
  - Dashboard: `/admin/dashboard`
  - Users: `/admin/user-management`, `/admin/user-management/[userId]`
  - Orders/subscriptions: `/admin/order-management`, `/admin/order-management/[orderId]`, `/admin/subscription-management`, `/admin/subscription-management/[subscriptionId]`, `/admin/delivery-postponement`
  - Products: `/admin/product-management/category`, `/admin/product-management/product`, `/admin/product-management/product/create`, `/admin/product-management/product/[id]`
  - Ingredients: `/admin/ingredients`, `/admin/ingredients-management`, `/admin/ingredients-management/create`, `/admin/ingredients-management/[id]`
  - Coupons: `/admin/coupon-management`, `/admin/coupon-management/create`, `/admin/coupon-management/[id]`
  - CMS/Content: `/admin/blog-management/blog`, `/admin/blog-management/blog/new`, `/admin/blog-management/blog/[id]`, `/admin/blog-management/category`, `/admin/blog-cms`, `/admin/cms-management/faqs`, `/admin/cms-management/faqs/manage`, `/admin/cms-management/faqs/[id]`, `/admin/cms-management/testimonials`, `/admin/cms-management/testimonials/create`, `/admin/cms-management/testimonials/[id]`, `/admin/all-pages`, `/admin/all-pages/create`, `/admin/all-pages/[pageId]`, `/admin/header-banners`, `/admin/header-banners/create`, `/admin/header-banners/[id]`, `/admin/landing-page`, `/admin/about-us`, `/admin/our-team`
  - Membership/settings: `/admin/membership`, `/admin/membership-plans`, `/admin/membership-plans/create`, `/admin/membership-plans/[planId]`, `/admin/settings`
  - Other: `/admin/coming-soon`

---

# Environment Configuration

## Environment files used

- Verified from repository:
  - `.env*` patterns are ignored in `.gitignore`
  - Base admin API URL uses `NEXT_PUBLIC_API_BASE_URL` (`src/store/api/baseApi.ts`)
  - Landing preview references `NEXT_PUBLIC_LANDING_PREVIEW_URL` (`src/components/landing-page/*`)

## Required environment variables

| Variable | Purpose | Status |
|----------|---------|--------|
| `NEXT_PUBLIC_API_BASE_URL` | Base URL for admin backend APIs | Verified from repository |
| `NEXT_PUBLIC_LANDING_PREVIEW_URL` | Landing preview source URL used in landing-page module | Verified from repository |

Do not commit secret values in `.env` files.

---

# Local Development Setup

## Commands to run

| Command | Purpose |
|---------|---------|
| `npm run dev` | Run local development server on port `8081` |
| `npm run build` | Create production build |
| `npm run start` | Start production server on port `8081` |
| `npm run build:standalone` | Build standalone output |
| `npm run start:standalone` | Run standalone output from `.next/standalone` |
| `npm run lint` | Run ESLint |

---

# Deployment Process

| Topic | Status | Notes |
|-------|--------|-------|
| Deployment script (`deploy.sh`) | Not Found in Repository | No deploy shell script in this branch |
| Central deployment runbooks | Partial | Team maintains deployment docs in `deployment_docs/` on `new_backend`; files not in this checkout |
| Docker deployment support | Verified from repository | Multi-stage Dockerfile builds Next standalone output |
| Container runtime port | Verified from repository | Docker runtime exposes `3000` |
| App runtime port via npm scripts | Verified from repository | `dev` and `start` run on `8081` |
| CI/CD workflows (this branch) | Not Found in Repository | No `.github/workflows` in this checkout |
| Hosting/provider details | Not Found in Repository | Not documented in this branch |
| Reverse proxy configuration | Not Found in Repository | Nginx/Caddy config not present in this branch |
| Environment matrix (dev/stage/prod) | Partial | Referenced as centralized in `deployment_docs/` on `new_backend` |

## Docker behavior (`Dockerfile`)

- Verified from repository:
  - Builder image: `node:20-alpine`
  - Uses `pnpm` via corepack and installs with frozen lockfile
  - Runs `pnpm build`
  - Runtime image: `node:20-alpine`
  - Copies `.next/standalone`, `.next/static`, and `public`
  - Starts app with `node server.js`

Operational implication (inferred from code):
- Runtime port handling differs by mode: Docker exposes `3000`, while non-container npm scripts target `8081`.

---

# External Integrations

| Integration | Purpose | Evidence |
|------------|---------|----------|
| Backend Admin API | Core admin CRUD/actions across modules | `src/store/api/*.ts` |
| DigitalOcean Spaces image hosts | Remote image domains for Next image optimization | `next.config.ts` |

Payment gateway behavior is backend-driven; this admin frontend consumes backend-admin APIs and does not store gateway secrets.

---

# Critical Business Logic

## Auth/session handling

- Verified from repository:
  - Middleware redirects unauthenticated users from protected routes to `/login`.
  - Middleware redirects authenticated users away from auth pages to `/admin/dashboard`.
  - API layer retries failed requests after refresh token call to `/auth/refresh`.

## Admin domain operations

- Verified from repository:
  - RTK Query modules exist for users, orders, subscriptions, products/categories/ingredients, coupons, blog/categories, FAQs/FAQ categories, static pages, testimonials, team/about-us, membership plans/CMS, landing pages, header banners, postponements, settings, and dashboard.

## Navigation and module structure

- Verified from repository:
  - Central route constants and sidebar composition support multi-module admin navigation patterns.

---

# Known Issues / Technical Debt

| Item | Evidence |
|------|----------|
| Default metadata text still template-like | `src/app/layout.tsx` title/description still "Create Next App" |
| Branch does not contain direct deployment runbooks | No `deployment_docs/` in this checkout |
| Potential runtime port confusion | npm scripts use `8081` while Docker image exposes `3000` |

---

# Operational Notes

| Topic | Status | Detail |
|-------|--------|--------|
| Branching strategy | Partial | Multiple branches exist (`main`, `new_backend`, `new_web_frontend`, `new_admin`); formal written strategy not in this branch |
| Release process | Partial | Centralized deployment docs exist on `new_backend`; branch-local script/pipeline not present |
| Feature flags | Not Found in Repository | No dedicated feature-flag framework found in this checkout |
| Required startup order | Verified from repository | Admin frontend requires reachable backend API (`NEXT_PUBLIC_API_BASE_URL`) |
| Backup/restore procedures | Not Found in Repository | |

---

# Infrastructure Ownership

| Asset | Status | Detail |
|-------|--------|--------|
| Repository hosting | Verified from repository | `https://github.com/nikunjgoyani5/viteezy-v2.git` |
| Application hosting | Not Found in Repository | No server/vendor detail in this branch |
| DNS/CDN providers | Partial | DO Spaces image hosts are referenced in Next image config; ownership details not documented |
| Backend service ownership | Partial | Admin depends on backend APIs, but ownership/ops details are outside this branch |

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

