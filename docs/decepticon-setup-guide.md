# Decepticon → cmmc20 Integration Setup Guide

**Author:** CatClaw 🐱  
**Last Updated:** 2026-05-07  
**Status:** Beta

---

## Overview

Decepticon is the fleet's red team/security scanning platform. It produces security findings (CVEs, CWEs, MITRE ATT&CK techniques) that are automatically mapped to CMMC 2.0 Level 2 compliance controls via the cmmc20 integration module.

## Architecture

```
┌─────────────┐     findings (JSON)     ┌──────────────────┐
│  Decepticon │ ──────────────────────► │  cmmc20 Backend   │
│  Scanners   │                         │  /integration/    │
│  (Batclaw)  │                         │                   │
└─────────────┘                         │  ┌─────────────┐  │
                                        │  │ CWE → CMMC  │  │
                                        │  │ MITRE → CMMC│  │
┌─────────────┐     findings (text)     │  │ Mapper      │  │
│   Mythos    │ ──────────────────────► │  │ Config Scan │  │
│  (Batclaw)  │                         │  └─────────────┘  │
└─────────────┘                         └──────────────────┘
                                                      │
                                                      ▼
                                        ┌──────────────────┐
                                        │ Compliance Impact │
                                        │ Assessments       │
                                        │ Knowledge Graph   │
                                        └──────────────────┘
```

## Components

### 1. Integration Module (`backend/src/integration/`)

| File | Purpose |
|------|---------|
| `types.ts` | Core types: DecepticonFinding, ComplianceImpact, KnowledgeGraph |
| `cwe-to-cmmc.ts` | 40+ CWE → CMMC practice mappings |
| `mitre-to-cmmc.ts` | 30+ MITRE ATT&CK → CMMC practice mappings |
| `mapper.ts` | Finding → Compliance impact engine + KG builder |
| `config-scanner.ts` | Infrastructure config security scanner |
| `index.ts` | Barrel exports |

### 2. Data Flow

```
Decepticon Finding
    │
    ├──► CWE Lookup ──────► CMMC Practices (with relevance)
    │
    ├──► MITRE Lookup ────► CMMC Practices (with relevance)
    │
    ├──► Merge Results ───► Deduplicate, prefer 'direct' relevance
    │
    ├──► Severity Map ────► Suggested Status
    │                       critical/high → noncompliant
    │                       medium/low → partial
    │                       informational → no change
    │
    └──► ComplianceImpact[] + KnowledgeGraph
```

### 3. Finding Format (Input)

```typescript
interface DecepticonFinding {
  id: string;                    // FIND-001
  title: string;
  severity: 'critical' | 'high' | 'medium' | 'low' | 'informational';
  cvssScore?: number;            // 0.0 - 10.0
  cwe: string[];                 // ['CWE-89', 'CWE-79']
  mitre: string[];               // ['T1190', 'T1059.004']
  affectedTarget: string;
  affectedComponent: string;
  description: string;
  impact: string;
  remediation: string;
  confidence: 'verified' | 'probable' | 'unverified';
  agent: string;                 // scanner name
  discoveredAt: string;          // ISO 8601
}
```

### 4. Compliance Impact (Output)

```typescript
interface ComplianceImpact {
  findingId: string;
  practiceId: string;            // 'AC.L1-3.1.3'
  domainId: string;              // 'AC'
  currentStatus: 'compliant' | 'partial' | 'noncompliant' | null;
  suggestedStatus: 'compliant' | 'partial' | 'noncompliant' | null;
  reasoning: string;
  confidence: 'high' | 'medium' | 'low';
  evidence: string;
}
```

## Setup

### Prerequisites
- cmmc20 backend running (Node.js 18+, PostgreSQL)
- Batclaw with Mythos or Decepticon scanners

### Step 1: Install Backend Dependencies

```bash
cd cmmc20/backend
npm install
npx prisma generate
npx prisma migrate deploy
```

### Step 2: Configure Environment

```env
# Required for integration
DATABASE_URL=postgresql://user:pass@localhost:5432/cmmc_saas
JWT_SECRET=your-secret-here

# Optional: for AI-powered analysis
ANTHROPIC_API_KEY=sk-ant-...
```

### Step 3: Import Integration Module

```typescript
import {
  mapFindingToCompliance,
  mapFindingsToCompliance,
  buildScanResult,
  buildKnowledgeGraph,
  scanConfig,
} from './integration';
```

### Step 4: Process Findings

```typescript
// Single finding
const impacts = mapFindingToCompliance(finding);

// Batch findings
const grouped = mapFindingsToCompliance(findings);

// Full scan result
const scanResult = buildScanResult(findings, 'target-asset', 'engagement-001');

// Knowledge graph
const kg = buildKnowledgeGraph(findings, impacts);

// Config scan
const configFindings = scanConfig(dockerfileContent, 'Dockerfile', 'web-server');
```

### Step 5: Config Scanning

The config scanner supports:

| File Type | Patterns Detected |
|-----------|-------------------|
| Dockerfile / docker-compose | Privileged mode, root user, host network, secrets in env, dangerous capabilities |
| nginx / .conf | Weak TLS, missing HSTS, version exposure |
| K8s / .yaml / .yml | Host PID, privileged pods, host network, root user, missing limits |
| Any file | Hardcoded credentials, debug mode, wildcard CORS |

## Mythos Integration

Batclaw runs Mythos scans that produce results in a compatible format. When scan results arrive:

1. Parse findings into `DecepticonFinding[]`
2. Run through `buildScanResult()` for compliance mapping
3. Generate report with compliance impact
4. Post summary to Telegram group (-1003589277936)

## Knowledge Graph

The integration builds a typed knowledge graph:

**Nodes:**
- `finding` — Security findings from scanners
- `cwe` — CWE weakness identifiers
- `mitre-technique` — MITRE ATT&CK technique IDs
- `cmmc-domain` — CMMC domains (AC, SC, SI, etc.)
- `cmmc-practice` — Individual CMMC practices

**Edges:**
- `has-cwe` — Finding → CWE
- `exploits` — Finding → MITRE technique
- `violates-control` — Finding → CMMC practice (negative impact)
- `implements-control` — Finding → CMMC practice (positive/no impact)
- `belongs-to-domain` — Practice → Domain

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Finding not mapped | Check if CWE/MITRE ID exists in mapping tables |
| Wrong severity → status | Review `severityToStatus()` logic in mapper.ts |
| Config scanner misses issue | Check if filename matches pattern detection in `getPatternsForFile()` |
| Knowledge graph duplicates | Ensure finding IDs are unique across scans |

## Extending Mappings

### Adding a CWE Mapping

Edit `backend/src/integration/cwe-to-cmmc.ts`:

```typescript
{
  cweId: 'CWE-NEW',
  cweName: 'New Weakness',
  practices: [
    { practiceId: 'SI.L1-3.14.1', relevance: 'direct', reasoning: '...' },
  ],
},
```

### Adding a MITRE Mapping

Edit `backend/src/integration/mitre-to-cmmc.ts`:

```typescript
{
  techniqueId: 'TXXXX',
  techniqueName: 'New Technique',
  tactic: 'initial-access',
  practices: [
    { practiceId: 'AC.L2-3.1.12', relevance: 'direct', reasoning: '...' },
  ],
},
```

## Fleet Contacts

| Role | Machine | IP | Purpose |
|------|---------|-----|---------|
| Batclaw 🦇 | Alienware | 100.69.146.72 | Mythos scanner, supervisor |
| CatClaw 🐱 | ubuntu-llm | 100.114.64.128 | cmmc20 owner, scan analysis |
| Pi 🍓 | rpibatclaw1 | 100.67.32.45 | Frontend |
