# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Key Documents

**READ THESE BEFORE MAKING CHANGES:**
- `docs/PRODUCT-OBJECTIVE.md` — The north star. Who, what, why, and what to build next.
- `docs/consultant-workflow.md` — The complete 5-phase CMMC consultant workflow.
- `docs/COMPETITIVE-LANDSCAPE.md` — Competitor analysis. Know who we're up against and what we must build to win.
- `docs/SEO-STRATEGY.md` — SEO strategy: keywords, content plan, technical SEO, backlinks.

## Product

**Level2Logic** — multi-tenant CMMC Level 2 gap-assessment SaaS for **Registered Practitioners (RPs) and cybersecurity consultants**. The README brands the product as Level2Logic; the package name (`cmmc-saas-platform`) is legacy. A consultant ("Organization") manages many `Client`s, each of which has `Assessment`s.

**Honest positioning** (do not contradict in code, copy, or seed data):
- We do NOT certify anyone — this is a self-assessment readiness tool, not a C3PAO product.
- No fabricated user counts, ratings, SOC 2 claims, or testimonials.
- **Strict No-CUI policy**: users are prohibited from uploading actual CUI, network diagrams, or credentials as evidence. The AI routes enforce this with a 2000-char limit and a regex that rejects "CUI", "Controlled Unclassified Information", "FOUO" — preserve these guards.

## Commands

```bash
# Root (delegates to backend + frontend)
npm run dev               # Concurrently: backend:5000 + frontend:3000
npm run build             # tsc backend + vite build frontend
npm test                  # Backend Jest then frontend Vitest
npm run lint              # ESLint both projects

# Backend (cd backend/)
npm run dev               # nodemon src/index.ts
npm test                  # jest (uses tsconfig.test.json with relaxed strictness)
npm test -- path/to/file.test.ts            # Single file
npm test -- -t "test name pattern"          # Single test by name
npm run db:migrate        # prisma migrate deploy (production migrations)
npm run db:push           # prisma db push --accept-data-loss (dev iteration only)
npm run db:seed           # ts-node prisma/seed.ts (uses tsconfig.seed.json)

# Frontend (cd frontend/)
npm test                  # vitest run
npm run test:watch        # vitest (watch)
npx vitest run src/__tests__/pages/LoginPage.test.tsx   # Single file
```

### Running locally

**SQLite demo (no Docker):**
```bash
./demo-quickstart.sh   # IMPORTANT: this overwrites prisma/schema.prisma with the SQLite schema
cd backend && DATABASE_URL='file:./dev.db' JWT_SECRET='demo-secret' JWT_REFRESH_SECRET='demo-refresh' npm run dev
cd frontend && npm run dev
```

**PostgreSQL (production-like):**
```bash
docker-compose up -d      # Postgres + Redis
npm run db:setup          # generate + migrate + seed
```

After running `demo-quickstart.sh`, `prisma/schema.prisma` is the SQLite schema. To return to Postgres, restore `schema.prisma` from git (`git checkout backend/prisma/schema.prisma`) before running Postgres migrations.

### Demo login
- `sarah@patriotprecision.com` / `demo2026` (admin)
- `mike@patriotprecision.com` / `demo2026` (assessor)

## Architecture

### Data model (`backend/prisma/schema.prisma`)
Multi-tenant consultant model:
```
Organization (the consultant firm)
  └── Client (the consultant's customer)
        └── Assessment
              └── PracticeAssessment ──► CmmcPractice ──► CmmcDomain
              └── Report
```
Tenant isolation: every query scopes through `req.user.organizationId`. For nested resources, scope via the relation (e.g., `assessment: { client: { organizationId: ... } }`).

The SQLite schema (`schema.sqlite.prisma`) is **older and lacks the Client model** — Assessments link directly to Organization there. When changing schema, update both files and remember SQLite uses `String` for fields the Postgres schema declares as `Json` (so `JSON.stringify()` before write, `JSON.parse()` after read).

### Backend (`backend/src/`)
- `index.ts` — Express app, middleware, route mounting. **`reportRoutes` is mounted on BOTH `/api/reports` and `/api/assessments`** for compatibility — keep both.
- `routes/` — `auth`, `organizations`, `clients`, `assessments`, `practiceAssessments`, `practices`, `reports`, `subscriptions`, `billing` (Stripe), `ai` (Anthropic), `upload` (S3 evidence)
- `services/` — `authService`, `subscriptionService`, `stripeService`, `aiService`, `emailService`, `s3Service`
- `middleware/` — `auth` (JWT, `requireAdmin`/`requireAssessorOrAdmin`/`requireAnyRole`), `validation` (Zod via `validateRequest({ body, params, query })`), `errorHandler` (custom `throwXError()` helpers for null narrowing)
- `utils/` — `compliance` (scoring, gaps, domain breakdown), `csvExport`, `pdfReport` (PDFKit), `logger` (winston)

### Frontend (`frontend/src/`)
- React 18 + Vite + TypeScript + TailwindCSS, React Query for server state
- `App.tsx` routing — note **assessment detail lives at `/clients/:id`**, not `/assessments/:id`
- Public routes (no login): `/`, `/login`, `/register`, `/forgot-password`, `/reset-password`, `/resources` (lead magnet)
- Authenticated routes wrapped in `<Layout>`: `/dashboard`, `/clients`, `/clients/:id`, `/subscription`, `/settings`, `/reports`, `/resources`
- Vite dev server proxies `/api` → `http://localhost:5000`
- `services/api.ts` — singleton axios client; `services/seoService.ts` — SEO metadata
- `hooks/useAuth.tsx` — auth context

### External integrations (all "mock mode" when keys absent — keep this behavior)
| Service | Trigger env var | Mock fallback |
|---|---|---|
| Stripe (`stripeService.ts`) | `STRIPE_SECRET_KEY` | Directly upgrades the Org tier and returns the success URL |
| Anthropic (`aiService.ts`) | `ANTHROPIC_API_KEY` | None — calls fail without key (model: `claude-3-5-haiku-20241022`) |
| AWS S3 (`s3Service.ts`) | `AWS_ACCESS_KEY_ID` | Returns a placeholder image URL |
| Resend email (`emailService.ts`) | `RESEND_API_KEY` or `SENDGRID_API_KEY` | Logs the email to winston |

`subscriptionTier` values in DB are `quick` (not "starter"), `professional`, `enterprise`. The `organizations` PUT route accepts `starter` in the Zod enum, but Stripe and seed data use `quick` — be careful when changing this.

## Conventions

### Backend TypeScript (very strict — `tsconfig.json`)
`strict`, `exactOptionalPropertyTypes`, `noUncheckedIndexedAccess`, `noPropertyAccessFromIndexSignature`, `noUnusedLocals`, `noUnusedParameters` are all on. This forces:
- `process.env['KEY']` (bracket notation, never dot)
- `req.params['id']!` non-null assertion after Zod validation
- `return throwXError(...)` pattern (the helpers throw, but `return` satisfies the type narrower)
- Optional fields passed to services typed as `string | undefined` explicitly

Tests use `tsconfig.test.json` which relaxes these — don't fight strict mode in tests by adding `as any` everywhere; if it's hard to express in production tsconfig, the API design is probably wrong.

### Auth middleware order
`authenticateToken` → `requireRole([...])` → `validateRequest({...})` → handler

### Prisma in tests
Mock with `jest.mock('@prisma/client', () => ({ PrismaClient: jest.fn(() => mockPrisma) }))`. Place the mock factory before any imports that touch the client.

### Frontend
- Tests: Vitest + `@testing-library/react`. `vi.mock()` factory cannot reference outer-scope variables — use `vi.fn()` inside, then `import` and cast after.
- Server state always through React Query (`useQuery`/`useMutation`/`queryClient.invalidateQueries`).
- Tailwind classes via `cn()` helper from `lib/utils.ts`.

### Seed data (`backend/prisma/`)
- 110 practices split across 4 files (`practices-ac.ts`, `practices-group2.ts`, `practices-group3.ts`, `practices-group4.ts`) and assembled in `practices.ts` via `expandDomain()`. There is a runtime `length !== 110` check at module load — preserve it.
- Practice IDs follow `{DOMAIN}.L2-{NIST_NUMBER}` (e.g., `AC.L2-3.1.1`).
- Demo entity IDs use UUID format `00000000-0000-0000-0000-00000000XXXX`.
- Demo password hash is bcrypt of `demo2026`.
- Seed must work for both Postgres (`Json` fields) and SQLite (`String` fields).

### Domain reference
14 CMMC domains have Level 2 practices, 2 (`RE` Recovery, `RM` Risk Management) are structural with 0 practices: AC(22), AT(3), AU(9), CM(9), IA(11), IR(3), MA(6), MP(9), PS(2), PE(6), RA(3), CA(4), SC(16), SI(7) = 110.

### Git
- Develop on the assigned feature branch; protected default branch is `master`.
- PR titles follow conventional commits (`feat:`, `fix:`, `docs:`, etc.) — CI enforces this in `pr-validation`.
- CI also greps for `TODO|FIXME|HACK|XXX` in `*.ts(x)` and fails on hits — avoid leaving them.
- **Destructive commands are blocked** by `.claude/settings.json` deny rules: `git reset --hard`, `git checkout .`, `git checkout -- <path>`, `git restore .`, `git clean -f[d][x]`, `git push --force`/`-f`/`--force-with-lease`, `git branch -D`, `git stash drop`/`clear`, `rm -rf`. If you genuinely need one of these, ask the user to run it themselves rather than disabling the rule. Diagnose the underlying problem first — if a rebase looks stuck, fix the conflict, don't `reset --hard`.
- Push feature branches as soon as the first commit lands (`git push -u origin <branch>`) so work survives a local-disk failure.
- Run `git status` before any operation that could touch untracked files. Investigate unfamiliar files/branches/locks rather than deleting — they may be the user's in-progress work.

### Architectural decisions
Significant decisions live in `docs/decisions/` as ADRs. Read these before "fixing" something that looks weird — most apparent inconsistencies are intentional (e.g., the dual route mount, the `quick`/`starter` tier-name split, the No-CUI policy).

## Demo company

"Patriot Precision Manufacturing" — fictional 35-person machine shop making military aircraft parts. Strong on physical security, weak on technical controls (no MFA, weak logging, no encryption). 41 of 110 practices pre-assessed, ~41% compliance. Lives in `backend/prisma/demo-data.ts`.

## Working in this repo

- Never use sub-agents to write files >500 lines. Split large practice files into chunks.
- The Codacy Cursor rule (`.cursor/rules/codacy.mdc`) instructs the IDE to run `codacy_cli_analyze` after edits — this only matters in the Cursor environment with the Codacy MCP server installed.

## Additional Key Documents
- `docs/PRODUCT-OBJECTIVE.md` — The north star. Defines customer, problem, features, and build priority. Read this if you're unsure what to build next.
- `docs/consultant-workflow.md` — The 5-phase consultant workflow with platform requirements per phase.

## Session Prompt
For starting a new Claude session, use `CLAUDE-SESSION-PROMPT.md` as the first message. It contains full context, build priorities, and rules.
