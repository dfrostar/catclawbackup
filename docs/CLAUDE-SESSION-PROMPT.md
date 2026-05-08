# Claude Session Prompt — Level2Logic CMMC Platform

**Use this when starting a new Claude session on the cmmc20 repo. Paste it as the first message.**

---

## Context

You are working on **Level2Logic**, a CMMC 2.0 compliance SaaS platform. The codebase is at `github.com/dfrostar/cmmc20`.

### What This Product Does

Level2Logic helps **compliance consultants** guide defense contractors through CMMC Level 2 certification. The end user is NOT the defense contractor directly — it's the **consultant** who manages 5–20 contractor clients simultaneously.

A typical engagement:
1. Consultant sends client intake questionnaire → client fills it out
2. Consultant walks through all 110 CMMC practices → assesses each one
3. Consultant collects evidence (screenshots, configs, policies) → maps to practices
4. Consultant generates SSP, POA&M, gap report → delivers to client
5. Client goes to C3PAO assessment → gets certified

**This process currently takes 200–400 consultant hours per client over 3–6 months. Our platform should reduce it to 50–100 hours over 1–2 months.**

### What's Already Built (Backend)

The backend API is complete and deployed on Render (`level2logic-backend.onrender.com`). Key endpoints:

| Endpoint | What It Does |
|----------|-------------|
| `POST /api/auth/register` | User registration |
| `POST /api/auth/login` | Login |
| `GET /api/clients` | List clients |
| `POST /api/assessments` | Create assessment |
| `GET /api/assessments/:id/practices` | Get practice assessments |
| `POST /api/assessments/:id/practices/:pid` | Score a practice |
| `POST /api/upload` | Upload evidence files |
| `POST /api/integrations/scan` | Map security findings to CMMC practices |
| `POST /api/integrations/config-scan` | Scan infrastructure configs for violations |
| `POST /api/integrations/cwe-lookup` | Look up practices by CWE ID |
| `GET /api/reports/:id/pdf` | Generate PDF report |

The integration module maps CWE/MITRE security findings to CMMC 2.0 practices. It's at `backend/src/integrations/` and the API routes are at `backend/src/routes/integrations.ts`.

### What Needs to Be Built (Frontend)

**The frontend is on Cloudflare Pages and connects to the backend via `VITE_API_URL=https://level2logic-backend.onrender.com/api`.**

The frontend currently has basic pages but is missing the **consultant workflow UI**. Here's what needs to be built:

#### 1. Client Intake Form (Priority: High)

A guided form the consultant sends to their client. The client fills it out and the data feeds into the assessment.

**Questions to include:**
- Organization info (name, CAGE code, DUNS, NAICS, employee count)
- CUI types handled (technical data, CDI, CTI)
- CUI flow (entry points, storage locations, exit points)
- System inventory (servers, workstations, cloud services, email)
- Network architecture (segmentation, VPN, remote access)
- People with CUI access (roles, not names)
- Existing security controls (MFA, encryption, logging, AV, training)
- Prior assessments (NIST 800-171 score, SPRS submission date)
- Contract info (prime/sub, contract numbers, CMMC level required)

**Save to:** `POST /api/clients/:id/intake` (needs new endpoint) or use existing client metadata fields.

#### 2. Interactive Assessment Walkthrough (Priority: High)

The core feature. Walk the consultant through all 110 practices one by one.

**For each practice, show:**
- Practice ID and title (e.g., "IA.L2-3.5.3 — Multifactor Authentication")
- Plain-English explanation ("This means you need MFA on all accounts that access CUI")
- Evidence needed ("Show me: MFA policy, config screenshot, account list")
- Status selector: Compliant / Partial / Noncompliant
- Evidence upload button
- Notes field

**Score calculation:**
- Start at 110, subtract per unmet control (-1 low, -3 medium, -5 high)
- Show running score as consultant works through practices
- Target: ≥88 for conditional, 110 for full certification

**Data source:** `GET /api/assessments/:id/practices` returns all practices with current status.

#### 3. Evidence Manager (Priority: High)

Organized evidence repository linked to practices.

**Features:**
- Upload evidence (screenshot, config file, policy document)
- Link evidence to specific practice
- Show evidence coverage matrix (which practices have evidence, which don't)
- Filter by practice, domain, status

**Data source:** `POST /api/upload` for files, `GET /api/assessments/:id/practices` for coverage.

#### 4. Config Scanner UI (Priority: Medium)

Upload infrastructure configs and see violations.

**Flow:**
1. Consultant uploads Dockerfile, nginx.conf, K8s manifest, or generic config
2. System scans for CMMC violations
3. Shows findings with affected practices, severity, and remediation guidance
4. Consultant can add findings to the assessment

**Data source:** `POST /api/integrations/config-scan`

#### 5. SSP Generator (Priority: High)

Auto-generate System Security Plan from assessment data.

**Content:**
- Organization overview (from intake)
- System boundary (from intake + assessment scope)
- Control implementations (from practice assessments)
- Evidence references (from evidence repository)
- POA&M (from gaps)

**Output:** PDF document formatted for C3PAO review.

**Data source:** `GET /api/reports/:id/pdf` or build a new endpoint.

#### 6. Consultant Portfolio Dashboard (Priority: Medium)

For consultants managing multiple clients.

**Shows:**
- All clients with compliance scores
- Color-coded by readiness level
- Open gaps count per client
- Timeline to C3PAO-ready

**Data source:** `GET /api/clients` + `GET /api/assessments` aggregated.

#### 7. Security Finding Import (Priority: Medium)

Import vulnerability findings from multiple sources → auto-map to practices.

**Sources supported:**
- **Pen test reports** — Upload JSON/CSV/paste findings from any pen test vendor
- **Mythos scans** — Automated code vulnerability discovery ($0.30–$1.50/scan). For software contractors, Mythos scans their repos and produces CWE-tagged findings.
- **Decepticon findings** — Red team engagement results with CWE/MITRE tags
- **Config scanner** — Upload Dockerfile, nginx.conf, K8s manifests → scan for CMMC violations

**Flow:**
1. Consultant selects source type (upload/Mythos/Decepticon/config)
2. System processes findings into standardized format
3. Maps CWE/MITRE IDs to CMMC practices via integration module
4. Shows affected practices with severity, impact, and remediation
5. Consultant adds findings to the assessment

**Data sources:** `POST /api/integrations/scan`, `POST /api/integrations/config-scan`

---

## Rules

1. **Read `docs/PRODUCT-OBJECTIVE.md` and `docs/consultant-workflow.md` before building anything.** These define the customer and the workflow.

2. **The end user is a compliance consultant, not a security engineer.** Use plain English everywhere. No jargon without explanation.

3. **No CUI.** Never ask users to paste actual CUI, credentials, or sensitive network details. Evidence fields must reject CUI keywords (the backend already enforces this).

4. **Test before committing.** Run `npm test` in the backend directory.

5. **The frontend is on Cloudflare Pages.** Push to master triggers auto-deploy. The `VITE_API_URL` env var is set in Cloudflare.

6. **The backend is on Render.** Push to master triggers auto-deploy. Database is PostgreSQL on Render. Evidence files go to Cloudflare R2.

7. **Consultant-first.** Every feature should work for a consultant managing multiple clients, not just a single contractor doing self-assessment.

---

## Competitive Advantages (Build These to Win)

Our competitors (Drata, Vanta, FutureFeed, Totem) charge $10K–25K/yr and are multi-framework bloatware. We win by being CMMC-specific and 10x cheaper.

**What we have that they don't:**
- CWE/MITRE → CMMC auto-mapping (pen test results → compliance impact in seconds)
- Config scanner (Docker/nginx/K8s → CMMC violations)
- Mythos code scanning integration (automated vuln discovery for software contractors)
- AI practice guidance in plain English (not generic GRC boilerplate)
- $99/mo starting price vs their $10K+/yr

**What we need to build to stay ahead:**
1. **Policy templates** — Pre-built, CMMC-specific policies the consultant can customize. Competitors have 50+. We need at least the top 10 (Access Control, IR, Training, Media Protection, etc.)
2. **SSP auto-generation** — The #1 deliverable consultants produce. If we generate it from assessment data, consultants save 20+ hours per client.
3. **Evidence-to-practice auto-linking** — Upload evidence → system suggests which practice it supports based on content analysis.
4. **Continuous monitoring** — After assessment, monitor for drift (MFA disabled, new users, config changes). Alert the consultant. This is what Drata does well.
5. **SPRS score calculator** — Auto-calculate from assessment data, show projection before submission.

**Do NOT build:**
- Multi-framework support (SOC 2, ISO 27001, HIPAA) — stay focused on CMMC
- Enterprise features (SSO, SCIM, audit logs) — that's for later tiers
- Mobile app — consultants use laptops

## Current Issues

- The frontend needs the assessment walkthrough UI — this is the #1 priority
- SSP/POA&M generators don't exist yet
- Evidence manager UI doesn't exist yet
- Config scanner has backend API but no UI
- The consultant portfolio view doesn't exist

---

## Your Task

Build the features listed above, starting with the highest priority items. The backend APIs exist — focus on the frontend UI that consumes them. Make the experience work for a compliance consultant who manages multiple defense contractor clients.

If you need a new backend endpoint, create it. If an existing endpoint doesn't return the right data shape, update it. But don't break existing functionality.

Start by reading the three key documents, then pick the highest-priority feature that's missing and build it.

### Key Documents to Read First
1. `docs/PRODUCT-OBJECTIVE.md` — What we're building and for whom
2. `docs/consultant-workflow.md` — The 5-phase consultant workflow
3. `docs/COMPETITIVE-LANDSCAPE.md` — Who we're competing against, what they have, what we need to build to win
