You are working on **Level2Logic**, a CMMC 2.0 compliance SaaS platform for defense contractors. The codebase is at `github.com/dfrostar/cmmc20`.

Before writing any code, read these documents in order:
1. `docs/PRODUCT-OBJECTIVE.md` — the north star: who the customer is, what the product does, what to build
2. `docs/consultant-workflow.md` — the 5-phase workflow a CMMC compliance consultant follows
3. `docs/COMPETITIVE-LANDSCAPE.md` — who we're competing against and what we must build to win
4. `docs/SEO-STRATEGY.md` — SEO strategy: keywords, content, technical SEO

If these documents conflict, PRODUCT-OBJECTIVE.md is the source of truth.

---

## What This Product Is

Level2Logic helps **compliance consultants** (not defense contractors directly) guide their clients through CMMC Level 2 certification. The consultant manages 5–20 contractor clients simultaneously. Each client needs to pass 110 security practices to get certified.

The product takes a consultant engagement from 200–400 hours down to 50–100 hours by automating:
- Client intake and discovery
- Assessment walkthrough (110 practices)
- Evidence collection and organization
- SSP and POA&M generation
- Pen test / vulnerability scan import and CMMC mapping

**The end user is a compliance consultant, not a security engineer. All language must be plain English. No jargon without explanation.**

---

## What's Already Built (Do Not Rebuild These)

### Backend API (Deployed on Render at level2logic-backend.onrender.com)

| File | What It Does |
|------|-------------|
| `backend/src/routes/auth.ts` | Registration, login, password reset |
| `backend/src/routes/assessments.ts` | CRUD for assessments |
| `backend/src/routes/practices.ts` | 110 CMMC practices |
| `backend/src/routes/clients.ts` | Client management |
| `backend/src/routes/reports.ts` | Report generation |
| `backend/src/routes/ai.ts` | AI-powered features |
| `backend/src/routes/subscriptions.ts` | Stripe billing |
| `backend/src/routes/upload.ts` | File upload |
| `backend/src/routes/integrations.ts` | Pen test import, config scan, CWE/MITRE lookup |
| `backend/src/integration/cwe-to-cmmc.ts` | 40+ CWE → CMMC mappings |
| `backend/src/integration/mitre-to-cmmc.ts` | 30+ MITRE ATT&CK → CMMC mappings |
| `backend/src/integration/config-scanner.ts` | Docker/nginx/K8s config scanner |
| `backend/src/integration/mapper.ts` | Finding → Compliance impact engine |
| `backend/src/services/s3Service.ts` | Cloudflare R2 evidence storage |

### Frontend (Deployed on Cloudflare Pages at level2logic.com)

| File | What It Does |
|------|-------------|
| `frontend/src/pages/LandingPage.tsx` | Marketing landing page |
| `frontend/src/pages/DashboardPage.tsx` | Basic dashboard |
| `frontend/src/pages/AssessmentDetailPage.tsx` | Assessment detail view |
| `frontend/src/pages/ClientsPage.tsx` | Client list |
| `frontend/src/pages/SubscriptionPage.tsx` | Pricing page |
| `frontend/src/services/api.ts` | API client (baseURL: VITE_API_URL) |
| `frontend/src/components/SEO.tsx` | React Helmet SEO component |
| `frontend/src/services/seoService.ts` | SEO meta tag service |

### Infrastructure

- **Frontend:** Cloudflare Pages, deploys from master branch
- **Backend:** Render, deploys from master branch
- **Database:** PostgreSQL on Render
- **Evidence Storage:** Cloudflare R2 (bucket: level2logic-evidence, account: 34b9da0044b7c5d5ba99edba7eacf9ab)
- **Domain:** level2logic.com (Cloudflare)
- **VITE_API_URL:** https://level2logic-backend.onrender.com/api

---

## What Needs to Be Built

Build these features in priority order. Each feature should be complete (frontend + any needed backend endpoints) before moving to the next.

### 1. Interactive Assessment Walkthrough (HIGHEST PRIORITY)

This is the core feature. A consultant walks through all 110 CMMC Level 2 practices, scores each one, and uploads evidence.

**Requirements:**
- Show all 110 practices organized by the 14 security domains (AC, AT, AU, CM, IA, IR, MA, MP, PE, PS, RA, CA, SC, SI)
- For each practice, display:
  - Practice ID (e.g., "IA.L2-3.5.3")
  - Practice title
  - Plain-English explanation: "What does this mean for a company your size?"
  - Evidence needed: "What should you look for?"
  - Status selector: Compliant / Partial / Noncompliant
  - Evidence upload button (connects to POST /api/upload)
  - Notes field
- Real-time compliance score calculation:
  - Start at 110 points
  - Subtract per unmet control: -1 (low severity), -3 (medium), -5 (high)
  - Show running score prominently
  - Target: ≥88 for conditional certification, 110 for full
- Progress indicator showing X/110 practices assessed
- Filter by domain, status (all/compliant/partial/noncompliant)
- Save progress automatically (don't lose work on page refresh)

**Data source:** GET /api/assessments/:id/practices returns all practices with current status. POST /api/assessments/:id/practices/:practiceId updates a practice assessment.

### 2. Evidence Manager

A place for consultants to upload, organize, and link evidence to practices.

**Requirements:**
- Upload evidence files (PDFs, screenshots, config exports) via drag-and-drop
- Link each piece of evidence to one or more practices
- Show evidence coverage matrix: which practices have evidence, which don't
- Evidence metadata: upload date, linked practices, file type
- Filter by practice, domain, or coverage status
- Bulk upload: select multiple files at once

**Data source:** POST /api/upload for file upload. GET /api/assessments/:id/practices for practice list.

### 3. SSP (System Security Plan) Generator

Auto-generate an SSP document from assessment data. This is the #1 deliverable consultants produce.

**Requirements:**
- Generate SSP from assessment data (client info, practice assessments, evidence references)
- Include: organization overview, system boundary, control implementations, evidence references
- Export as PDF
- Include POA&M section for noncompliant practices
- Format should be professional and C3PAO-ready

**Data source:** GET /api/reports/:id/pdf (if it exists) or create a new endpoint that combines assessment + client + evidence data.

### 4. Config Scanner UI

Frontend for the existing config scanner API.

**Requirements:**
- Upload config files (Dockerfile, nginx.conf, K8s manifests, or paste text)
- Show scan results: findings with severity, affected practice, description, remediation
- Allow consultant to add findings to the assessment
- Show which patterns were checked

**Data source:** POST /api/integrations/config-scan

### 5. Pen Test / Scan Import UI

Frontend for importing vulnerability scan results.

**Requirements:**
- Upload pen test report (JSON or CSV format)
- Or paste findings manually (CWE IDs, MITRE technique IDs, severity, description)
- Show mapped CMMC practices with impact assessment
- Allow consultant to add findings to the assessment

**Data source:** POST /api/integrations/scan

### 6. Consultant Portfolio Dashboard

For consultants managing multiple clients.

**Requirements:**
- Show all clients in a grid/table
- Each client shows: name, compliance score, open gaps, status (not started / in progress / ready)
- Color-coded by readiness level (red < 80, yellow 80–87, green ≥88)
- Click into any client to see their assessment
- Summary stats: total clients, average score, clients ready for C3PAO

**Data source:** GET /api/clients, GET /api/assessments (aggregate per client)

### 7. SEO Implementation

Update the frontend for search engine optimization.

**Requirements:**
- Create `public/sitemap.xml` with all public pages
- Create `public/robots.txt` (allow public pages, block /dashboard, /api)
- Update meta tags in `seoService.ts` for consultant-first positioning:
  - Title: "CMMC Compliance Software for Consultants | Level2Logic"
  - Description: "The CMMC assessment platform consultants use to manage 20 clients in the time it takes to manage 3. $99/mo. CWE mapping, config scanner, AI guidance."
- Add structured data (JSON-LD) for SoftwareApplication on landing page
- Add FAQ schema on pages with Q&A content
- Add Open Graph tags with branded image
- Add canonical URLs to all pages

### 8. Policy Templates

Create pre-built CMMC policy templates that consultants can customize for clients.

**Requirements:**
- Create at least these 10 policy templates as downloadable documents or in-app templates:
  1. Access Control Policy (AC)
  2. Incident Response Policy (IR)
  3. Security Awareness Training Policy (AT)
  4. Media Protection Policy (MP)
  5. Identification and Authentication Policy (IA)
  6. Configuration Management Policy (CM)
  7. System and Communications Protection Policy (SC)
  8. Audit and Accountability Policy (AU)
  9. Physical Protection Policy (PE)
  10. Risk Assessment Policy (RA)
- Each template should have: purpose, scope, policy statements, enforcement, review cycle
- Templates should be branded with Level2Logic but customizable
- Consultants can edit and download as PDF

---

## Rules for Building

1. **Plain English everywhere.** The user is a compliance consultant, not a security engineer. Explain what things mean. Example: Instead of "Implement multifactor authentication per IA.L2-3.5.3", say "You need MFA (multi-factor authentication) on all accounts that access sensitive data — this means a password plus a code from your phone."

2. **No CUI.** Never ask users to paste actual CUI, credentials, or sensitive network details. The backend already enforces this with character limits and keyword rejection — preserve those guards.

3. **Test before committing.** Run `npm test` in the backend directory. Make sure existing tests pass.

4. **Don't break existing features.** If you change a backend endpoint, verify the existing frontend still works with it.

5. **Consultant-first design.** Every feature should work for a consultant managing multiple clients, not just a single contractor doing self-assessment.

6. **The frontend deploys from master on Cloudflare Pages.** Push to master triggers auto-deploy.

7. **The backend deploys from master on Render.** Push to master triggers auto-deploy.

8. **Evidence files go to Cloudflare R2.** The s3Service.ts is already configured for R2. Don't change the storage provider.

9. **Read the four key documents before building.** They define the customer, workflow, competition, and SEO strategy. If you're unsure what to build, refer to PRODUCT-OBJECTIVE.md.

10. **Commit frequently with clear messages.** Use conventional commit format: feat(scope): description, fix(scope): description, docs: description.

---

## Current State of the Frontend

The frontend has basic pages (landing, dashboard, clients, assessments) but is missing the core consultant workflow UI. The assessment detail page exists but doesn't have the interactive 110-practice walkthrough described above. The dashboard exists but is contractor-focused, not consultant-focused.

Start with the Interactive Assessment Walkthrough — it's the #1 priority. Build it as a new page or significantly enhance the existing AssessmentDetailPage. Make it work end-to-end: load practices, display them grouped by domain, let the user score each one, upload evidence, and see their running score update in real-time.

After the assessment walkthrough is working, move to the Evidence Manager, then SSP Generator, then the remaining features.

---

## Key Technical Details

- React 18 with TypeScript
- Tailwind CSS + shadcn/ui components
- React Router for routing
- React Query for data fetching
- React Hook Form + Zod for forms
- Recharts for data visualization
- React Helmet for SEO
- Vite for build

The API client is at `frontend/src/services/api.ts`. The base URL comes from VITE_API_URL. In production it's https://level2logic-backend.onrender.com/api.

If you need to create new API endpoints, add them to the backend in `backend/src/routes/`. Follow the existing patterns (Prisma for DB, Zod for validation, authenticateToken middleware for auth).

If you need to add new database models, update `backend/prisma/schema.prisma` and create a migration with `npx prisma migrate dev`.
