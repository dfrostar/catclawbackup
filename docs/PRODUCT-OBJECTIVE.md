# Level2Logic — Product Objective & North Star

**This document defines what Level2Logic IS, who it serves, and what it must do. Read this before writing any code.**

---

## One-Sentence Pitch

Level2Logic helps compliance consultants guide defense contractors through CMMC Level 2 certification — from "where do we stand?" to "C3PAO-ready" — in weeks instead of months.

---

## Who Is the Customer?

**Primary buyer:** CMMC compliance consultants (Registered Practitioners)
- Manage 5–20 defense contractor clients simultaneously
- Charge $15K–50K per client engagement
- Need to be 10x more efficient to scale their business

**End user:** Small/mid defense contractors (10–500 employees)
- Machine shops, parts manufacturers, engineering firms
- Don't speak security — need plain-English guidance
- Budget-conscious ($99–299/mo is their range)
- Facing November 2026 deadline

---

## What Problem Does It Solve?

**The consultant's problem today:**
- Discovery: 2 weeks of interviews and document collection
- Gap Assessment: 6–8 weeks manually reviewing 110 practices with spreadsheets
- Evidence: Weeks collecting, organizing, and mapping evidence to practices
- Reporting: Days generating SSP, POA&M, and gap reports in Word/Excel
- Total: 200–400 consultant hours per client over 3–6 months

**What Level2Logic does:**
- Discovery: Guided intake questionnaire, 30 minutes instead of 2 weeks
- Gap Assessment: Interactive walkthrough of 110 practices with AI guidance
- Evidence: Upload configs, screenshots, policies → auto-map to practices
- Reporting: One-click SSP, POA&M, and gap report generation
- Total: 50–100 consultant hours per client over 1–2 months

---

## What Level2Logic IS NOT

- ❌ **Not a C3PAO assessment tool** — We don't certify anyone
- ❌ **Not a security scanner** — We don't run pen tests or vuln scans
- ❌ **Not a managed service** — We're software, not consultants
- ❌ **Not for CUI** — Users must not upload actual CUI, credentials, or network diagrams
- ❌ **Not a GRC platform** — We're CMMC-specific, not multi-framework (yet)

---

## Core Features (Build These First)

### 1. Client Intake & Scoping
**What:** Guided questionnaire that collects everything the consultant needs
**Who uses it:** Consultant sends to client, client fills it out
**Output:** Organization profile, system inventory, CUI data flow map, existing security posture

### 2. Interactive Assessment (110 Practices)
**What:** Walk through all 110 CMMC Level 2 practices one by one
**Who uses it:** Consultant (with client input)
**For each practice:**
- Plain-English explanation ("What does this mean?")
- Evidence needed ("What should I look for?")
- Status selection (Compliant / Partial / Noncompliant)
- Evidence upload (screenshot, config, policy)
- Notes field
**Output:** Real-time compliance score (SPRS-style)

### 3. Pen Test / Scan Import
**What:** Upload vulnerability scan results → auto-map to affected practices
**Who uses it:** Consultant
**How:** Uses CWE→CMMC and MITRE→CMMC mapping tables
**Output:** "Your pen test found CWE-89 (SQLi) — this affects practices SI.L1-3.14.1 and SI.L2-3.14.2"

### 4. Config Scanner
**What:** Upload infrastructure configs → scan for CMMC violations
**Who uses it:** Consultant
**Supports:** Docker, nginx, Kubernetes, generic configs
**Output:** Violations mapped to practices with remediation guidance

### 5. Evidence Repository
**What:** Organized store of all evidence, linked to practices
**Who uses it:** Consultant uploads, assessor reviews
**Structure:** One folder per practice, with metadata (date, owner, validated by)
**Output:** Evidence matrix showing coverage

### 6. SSP Generator
**What:** Auto-generate System Security Plan from assessment data
**Who uses it:** Consultant reviews, client signs
**Content:** Control descriptions, implementation details, evidence references
**Output:** PDF document formatted for C3PAO review

### 7. POA&M Builder
**What:** For each gap, create a remediation plan with owners and dates
**Who uses it:** Consultant + client IT team
**Fields:** Gap description, remediation steps, owner, target date, status
**Output:** POA&M document, task tracker

### 8. Compliance Dashboard
**What:** Real-time view of compliance status across all clients (for consultant) or one client (for contractor)
**Who uses it:** Everyone
**Shows:** Score by domain, open gaps, evidence coverage, timeline to readiness
**Output:** At-a-glance health check

---

## Subscription Tiers

| Tier | Price | Target | Features |
|------|-------|--------|----------|
| **Starter** | $99/mo | Self-serve contractors | Self-assessment, basic scoring, gap identification |
| **Professional** | $799/mo | Mid-size contractors | Full assessment, evidence, SSP/POA&M, reports |
| **Consultant** | $1,999/mo | Compliance consultants | Multi-client management, portfolio dashboard, white-label |

---

## Technical Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Level2Logic Platform                       │
│                                                               │
│  Frontend (React + TypeScript)                    Backend (Node + Express)  │
│  ├─ Assessment UI                                 ├─ Auth (JWT)              │
│  ├─ Client Dashboard                              ├─ Assessments API         │
│  ├─ Consultant Portfolio                          ├─ Evidence API            │
│  ├─ Evidence Manager                              ├─ Integration API        │
│  └─ Report Generator                              ├─ Reports API            │
│                                                    └─ AI API (Anthropic)    │
│                                                               │
│  Integration Module (Built ✅)                                │
│  ├─ CWE → CMMC Mapper (40+ CWEs)                             │
│  ├─ MITRE → CMMC Mapper (30+ techniques)                     │
│  ├─ Config Scanner (Docker, nginx, K8s)                      │
│  └─ Knowledge Graph Builder                                   │
│                                                               │
│  Infrastructure                                               │
│  ├─ PostgreSQL (Render)                                       │
│  ├─ Cloudflare R2 (Evidence storage)                          │
│  ├─ Cloudflare Pages (Frontend)                               │
│  └─ Render (Backend)                                          │
└─────────────────────────────────────────────────────────────┘
```

---

## What's Already Built

| Component | Status | File |
|-----------|--------|------|
| Auth system | ✅ Done | `backend/src/routes/auth.ts` |
| Assessment CRUD | ✅ Done | `backend/src/routes/assessments.ts` |
| Practice management | ✅ Done | `backend/src/routes/practices.ts` |
| Client management | ✅ Done | `backend/src/routes/clients.ts` |
| Reports | ✅ Done | `backend/src/routes/reports.ts` |
| AI integration | ✅ Done | `backend/src/routes/ai.ts` |
| Subscriptions | ✅ Done | `backend/src/routes/subscriptions.ts` |
| File upload | ✅ Done | `backend/src/routes/upload.ts` |
| CWE→CMMC mapper | ✅ Done | `backend/src/integration/cwe-to-cmmc.ts` |
| MITRE→CMMC mapper | ✅ Done | `backend/src/integration/mitre-to-cmmc.ts` |
| Config scanner | ✅ Done | `backend/src/integration/config-scanner.ts` |
| Integration API | ✅ Done | `backend/src/routes/integrations.ts` |
| R2 storage support | ✅ Done | `backend/src/services/s3Service.ts` |
| SSP generator | ❌ Not built | — |
| POA&M builder | ❌ Not built | — |
| Consultant portfolio | ❌ Not built | — |
| Evidence manager UI | ❌ Not built | — |
| Config scanner UI | ❌ Not built | — |

---

## What to Build Next (Priority Order)

| # | Feature | Why First | Effort |
|---|---------|-----------|--------|
| 1 | **Interactive Assessment UI** | Core product — this IS the value | High |
| 2 | **Evidence Manager** | Consultants spend 40% of time here | Medium |
| 3 | **SSP Generator** | The #1 deliverable consultants produce | High |
| 4 | **Config Scanner UI** | Makes the integration module visible | Low |
| 5 | **POA&M Builder** | Second most important deliverable | Medium |
| 6 | **Consultant Portfolio** | Differentiator for $1,999/mo tier | Medium |

---

## Rules for AI Agents Working on This Codebase

1. **Read this document first.** Understand who the customer is and what they need.
2. **Don't break the No-CUI policy.** Evidence fields must reject CUI keywords.
3. **Test before committing.** Run `npm test` in backend before pushing.
4. **Don't add features outside this scope.** If it's not in "What to Build Next," ask first.
5. **Consultant-first, contractor-second.** Every feature should work for a consultant managing multiple clients.
6. **Plain English over jargon.** The user is a compliance consultant, not a security engineer.
