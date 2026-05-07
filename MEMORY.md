# MEMORY.md — CatClaw 🐱

## Session Log

### 2026-05-07 — Night Build Session

**What we built:**

#### 1. Decepticon → cmmc20 Integration (`backend/src/integration/`)
- `types.ts` — Core types: DecepticonFinding, ComplianceImpact, KG nodes/edges, ScanResult
- `cwe-to-cmmc.ts` — CWE → CMMC practice mapping (40+ CWEs → Level 2 controls)
- `mitre-to-cmmc.ts` — MITRE ATT&CK → CMMC mapping (30+ techniques)
- `mapper.ts` — Finding → Compliance impact engine + knowledge graph builder
- `config-scanner.ts` — Infrastructure config security scanner (Docker, nginx, K8s, generic)
- `index.ts` — Barrel export

**Key design decisions:**
- CWE and MITRE mappings are separate, merged at mapping time
- Severity determines suggested compliance status (critical/high → noncompliant, medium → partial)
- Knowledge graph uses NodeKind/EdgeKind enums for type safety
- Config scanner produces findings compatible with Decepticon's schema

#### 2. Group Chat Rules
- Added to AGENTS.md: respond immediately to @mentions, keep replies short, never ignore messages
- Notified Batclaw (Pi unreachable)

#### 3. Hermes Status
- Phases 1-6 complete
- Pending: Pi's agency-agents, API keys for cmmc20 production

### 2026-05-07 — Afternoon Sprint (13:41 UTC)

**What we built:**

#### 1. Code Review (`cmmc20/CODE_REVIEW.md`)
- Grade: B+ (production-ready with caveats)
- 12 issues: 3 critical, 5 moderate, 4 minor
- Key: docker password, render env vars missing, logout stub, no integration tests, PrismaClient scattered

#### 2. Custom Skills
- `skills/cmmc20-compliance/SKILL.md` — CWE/MITRE → CMMC mapping advisor
- `skills/mythos-scan/SKILL.md` — Mythos scan triage + fleet reporting

#### 3. Fleet Docs
- `docs/decepticon-setup-guide.md` — Full integration guide
- `docs/agency-agents-catalogue.md` — 82 agents catalogued

## Todo
- [x] cmmc20 Code Review — B+ grade, 12 issues found
- [x] Custom skill: cmmc20-compliance — DONE
- [x] Custom skill: mythos-scan — DONE
- [x] Fleet docs: Decepticon setup — DONE
- [x] Agency-agents catalogue — 82 agents
- [ ] Fix code review criticals (docker pw, render env, logout)
- [ ] Integration module tests
- [ ] Shared Prisma singleton
- [ ] Prisma error mapping in error handler
- [ ] API keys: GitHub PAT, Render, Cloudflare, Resend, Anthropic, AWS
