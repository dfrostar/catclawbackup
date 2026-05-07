# CMMC 2.0 Research Synthesis

**Prepared by:** CatClaw 🐱  
**Date:** 2026-05-07  
**Sources:** 7 research docs loaded into open-notebook, web research, repo analysis

---

## 1. What Is CMMC 2.0?

CMMC (Cybersecurity Maturity Model Certification) is the DoD's mandatory cybersecurity standard for contractors handling Controlled Unclassified Information (CUI). It replaces self-attestation with verified compliance.

**Three levels:**
- **Level 1 — Foundational:** 17 basic practices. Self-assessment. For Federal Contract Information (FCI).
- **Level 2 — Advanced:** 110 practices from NIST SP 800-171 Rev 2. Third-party assessment (C3PAO) required. This is the big one.
- **Level 3 — Expert:** 172 practices. Government-led assessment only.

**The crisis:** 80,000 companies need Level 2. ~1,100 have it. Phase 2 (mandatory third-party assessments) starts **November 2026**.

---

## 2. Market Opportunity

| Metric | Value |
|--------|-------|
| Total DoD supply chain | 300,000+ companies |
| Need Level 2+ | ~100,000 companies |
| Total compliance cost per company | $75,000 – $200,000+ |
| C3PAO assessment fee alone | $30,000 – $70,000 |
| Consultant gap assessment | $15,000 – $50,000+ |
| C3PAO wait times | 12–18+ months |
| Market size (software + services) | $3–5B |

**Competitive landscape:**

| Category | Players | Price/yr |
|----------|---------|----------|
| Infrastructure (CUI environments) | PreVeil, Kiteworks | $5K–15K |
| Multi-framework GRC | Drata, Vanta, Secureframe | $10K–25K |
| CMMC-specific tools | FutureFeed, Totem | $3K–21K |
| Managed services | Summit 7 | $250K+ all-in |

**The gap:** No affordable, CMMC-specific tool for small contractors. That's where $99–299/mo platforms win.

---

## 3. The Customer: CMMC Compliance Advisors

### Who They Are
- Compliance consultants helping DoD contractors prepare for Level 2
- Manage multiple clients, each at different readiness stages
- Not security engineers — they're compliance experts who translate security into audit-ready documentation

### What They Do
1. **Gap assessments** — walk clients through 110 practices, identify what's missing
2. **Evidence collection** — gather policies, configs, logs, scan results
3. **Remediation planning** — prioritize fixes by risk and cost
4. **SSP/POA&M creation** — the master documents assessors review
5. **C3PAO preparation** — prep clients for the third-party assessment

### Their Pain Points
| Pain Point | How a Platform Helps |
|------------|---------------------|
| "My client gave me a pen test report — which 110 practices are affected?" | Auto-map CWE/MITRE → practices in seconds |
| "I'm tracking 15 clients — which ones are at risk?" | Portfolio dashboard with domain-level heatmaps |
| "Evidence collection takes weeks" | Upload configs → auto-generate evidence entries |
| "I need a remediation plan with cost estimates" | AI-generated prioritized roadmap |
| "The SSP is 200 pages and I have to maintain it" | Auto-generate from assessment data |

---

## 4. The 14 Security Domains (Level 2)

| Code | Domain | Practices | Common Gaps for Small Contractors |
|------|--------|-----------|-----------------------------------|
| AC | Access Control | 22 | No least privilege, shared accounts, weak remote access |
| AT | Awareness & Training | 3 | No security training program, no insider threat awareness |
| AU | Audit & Accountability | 9 | Logs not reviewed, no centralized logging, no audit trail |
| CM | Configuration Management | 11 | No baseline configs, no change control, unnecessary services |
| IA | Identification & Authentication | 11 | **No MFA** (most critical gap), weak passwords |
| IR | Incident Response | 3 | No IR plan, no defined roles, no testing |
| MA | Maintenance | 6 | Unsupervised maintenance, no remote access controls |
| MP | Media Protection | 9 | Unencrypted USB drives, no media sanitization |
| PS | Personnel Security | 2 | No background checks, no access termination process |
| PE | Physical Protection | 6 | No server room access controls, no visitor logs |
| RA | Risk Assessment | 3 | No vulnerability scanning, no risk assessments |
| CA | Security Assessment | 4 | No SSP, no POA&M, no control assessments |
| SC | System & Comms Protection | 16 | No encryption in transit, no FIPS-validated crypto |
| SI | System & Info Integrity | 7 | No patching process, no malware protection, no monitoring |

**Top 5 gaps** (by frequency in small contractors):
1. **No MFA** (IA.L2-3.5.3) — 80%+ of small contractors fail this
2. **No encryption** (SC.L2-3.13.11) — CUI sitting unencrypted
3. **Poor logging** (AU.L2-3.3.1) — logs exist but never reviewed
4. **No IR plan** (IR.L2-3.6.1) — ad-hoc incident handling
5. **Weak remote access** (AC.L2-3.1.12) — VPN without MFA or monitoring

---

## 5. Timeline & Enforcement

| Phase | Date | Requirement |
|-------|------|-------------|
| Phase 1 | Nov 2025 – Nov 2026 | Self-assessments for ~65% of new contracts |
| Phase 2 | Nov 2026+ | C3PAO third-party assessments mandatory |
| Phase 3 | Nov 2027+ | Extends to existing contracts |

**Contract flow-down:** DFARS 252.204-7021 requires primes to flow CMMC requirements to subcontractors. Non-compliance = cannot bid on or hold DoD contracts involving CUI.

**The rush:** With 80,000 companies needing certification and ~800 C3PAO assessors, scheduling is already 12–18 months out. Companies waiting will miss contracts.

---

## 6. What a CMMC Platform Should Build for Advisors

### Core Features (Already in cmmc20)
- ✅ Self-assessment across all 110 practices
- ✅ Compliance scoring by domain
- ✅ Gap identification and tracking
- ✅ Report generation (PDF)
- ✅ Multi-user with role-based access

### High-Value Additions (From Research)

#### A. Security Finding → Compliance Mapper
**What:** Upload or paste vulnerability scan results → auto-map to affected CMMC practices  
**Why:** Saves advisors hours of manual cross-referencing  
**How:** Use CWE→CMMC and MITRE→CMMC mapping tables (already built in integration module)

**API endpoint:** `POST /api/integrations/decepticon/scan`
**UI:** Upload panel on assessment page, shows affected practices with status impact

#### B. Config Scanner for Evidence Collection
**What:** Upload Dockerfile, nginx.conf, K8s manifests → scan for CMMC violations  
**Why:** Infrastructure evidence is the hardest to collect manually  
**How:** Config scanner module (already built)

**API endpoint:** `POST /api/integrations/decepticon/config-scan`  
**UI:** "Upload Config" button on evidence collection page

#### C. Client Portfolio Dashboard
**What:** Advisor sees all clients at once — compliance score, risk level, open gaps  
**Why:** Advisors manage 5–20 clients simultaneously  
**How:** Aggregated view from existing assessment data

**UI:** New dashboard tab with cards per client, color-coded by domain

#### D. AI-Powered Practice Guidance
**What:** For each practice, AI explains what it means in plain English for the client's specific situation  
**Why:** Small contractors don't speak security jargon  
**How:** LLM integration (Anthropic/OpenAI) with practice descriptions as context

**Already partially exists** in the go-to-market plan as "AI-Guided" tier ($299/mo)

#### E. Remediation Plan Generator
**What:** Based on gaps, generate prioritized remediation plan with cost estimates  
**Why:** This is what consultants charge $15K–50K for  
**How:** Rule-based + AI: map gaps to common fixes, estimate effort

---

## 7. Technical Architecture for These Features

```
┌─────────────────────────────────────────────────┐
│                 cmmc20 Platform                  │
│                                                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────────┐  │
│  │ Assessment│  │ Evidence  │  │  Portfolio   │  │
│  │  Engine   │  │ Collector │  │  Dashboard   │  │
│  └────┬─────┘  └────┬─────┘  └──────┬───────┘  │
│       │              │               │           │
│  ┌────┴──────────────┴───────────────┴────────┐ │
│  │         Integration Module                  │ │
│  │  ┌─────────┐  ┌──────────┐  ┌───────────┐  │ │
│  │  │CWE→CMMC │  │MITRE→CMMC│  │Config Scan│  │ │
│  │  │  Mapper │  │  Mapper  │  │  Engine   │  │ │
│  │  └─────────┘  └──────────┘  └───────────┘  │ │
│  │  ┌─────────────────────────────────────┐    │ │
│  │  │    Knowledge Graph Builder          │    │ │
│  │  └─────────────────────────────────────┘    │ │
│  └────────────────────────────────────────────┘ │
│                                                  │
│  ┌────────────────────────────────────────────┐ │
│  │              AI Layer                       │ │
│  │  Practice Guidance │ Remediation Planner   │ │
│  │  Report Generator  │ Evidence Review       │ │
│  └────────────────────────────────────────────┘ │
│                                                  │
│  ┌──────────────┐  ┌─────────────────────────┐ │
│  │  PostgreSQL  │  │  S3 (Evidence Storage)  │ │
│  └──────────────┘  └─────────────────────────┘ │
└─────────────────────────────────────────────────┘
```

---

## 8. Recommended Build Priority

| Priority | Feature | Effort | Value |
|----------|---------|--------|-------|
| 🔴 P0 | Security Finding → Compliance Mapper API | Medium | High — saves hours per client |
| 🔴 P0 | Config Scanner for evidence | Medium | High — unique differentiator |
| 🟡 P1 | Client Portfolio Dashboard | Medium | High — advisor daily driver |
| 🟡 P1 | AI Practice Guidance | Low | High — $299/mo tier justify |
| 🟢 P2 | Remediation Plan Generator | High | Medium — complex, but defensible |
| 🟢 P2 | Auto-evidence from scan results | Medium | Medium — nice-to-have |

---

## 9. Key Takeaways

1. **The market is massive and urgent.** 80,000 companies, November deadline, most still uncertified.

2. **Small contractors are underserved.** They can't afford $50K consultants or $250K managed services. A $99–299/mo tool that tells them where they stand is an easy sell.

3. **The integration module we built is the right direction.** CWE/MITRE → CMMC mapping saves advisors the most painful manual work.

4. **Focus on the advisor, not the contractor.** Advisors are the buyers — they manage multiple clients and need portfolio tools.

5. **AI is the moat.** Practice guidance, evidence review, and remediation planning powered by LLMs is what separates cmmc20 from spreadsheets.

6. **The timeline creates urgency.** Phase 2 starts November 2026. Companies that haven't started will pay premium prices for tools that help them catch up.

---

*This synthesis was generated from 7 research sources loaded into open-notebook, combined with web research and the cmmc20 codebase analysis.*
