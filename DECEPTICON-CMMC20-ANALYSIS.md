# Decepticon → cmmc20 Integration Analysis

## Overview
Decepticon is an autonomous red team agent by PurpleAILAB. This document analyzes which components can be adapted for the cmmc20 CMMC compliance platform.

**Repository:** `github.com/PurpleAILAB/Decepticon`
**Clone location:** `/home/node/.openclaw/workspace/Decepticon/`

---

## Architecture Summary

Decepticon runs as a Docker Compose stack with 7 services:
- **LiteLLM** — LLM proxy gateway (model routing, auth, billing)
- **PostgreSQL** — Persistent storage
- **Neo4j** — Attack chain graph database
- **Sandbox** — Isolated Kali container for executing tools
- **LangGraph** — Agent orchestration API (port 2024)
- **Web Dashboard** — Next.js UI (port 3000)
- **CLI** — Interactive terminal UI

Two networks: `decepticon-net` (management) and `sandbox-net` (operations).

---

## 16 Specialized Agents

| Agent | Phase | Purpose | cmmc20 Relevance |
|-------|-------|---------|-----------------|
| **Recon** | Reconnaissance | Network scanning, service enumeration, vuln discovery | ⭐⭐⭐ HIGH — automated security posture assessment |
| **Scanner** | Vuln Research | Codebase scanning, heuristic SAST (10^5-10^6 files) | ⭐⭐⭐ HIGH — compliance evidence scanning |
| **Detector** | Vuln Research | Promotes candidate vulns from source analysis | ⭐⭐ MEDIUM — gap detection |
| **Verifier** | Vuln Research | PoC validation, zero-false-positive gate | ⭐⭐ MEDIUM — compliance validation |
| **Analyst** | Vuln Research | Full research: CVE, fuzzing, attack chains | ⭐⭐⭐ HIGH — vulnerability-to-control mapping |
| **Exploit** | Initial Access | Targeted exploitation | ⭐ MEDIUM — only if offering offensive validation |
| **Exploiter** | Post-Exploit | Privilege escalation, lateral movement | ⭐ LOW — beyond CMMC scope |
| **Patcher** | Remediation | Auto-patch vulnerabilities | ⭐⭐ MEDIUM — remediation assistance |
| **AD Operator** | Active Directory | AD/Windows attacks (DCSync, Kerberoasting) | ⭐⭐ MEDIUM — AD compliance checks |
| **Cloud Hunter** | Cloud | AWS/GCP/Azure misconfig detection | ⭐⭐⭐ HIGH — cloud compliance |
| **Reverser** | Binary | Binary analysis, packer detection | ⭐ LOW |
| **Contract Auditor** | Smart Contracts | Solidity security | ⭐ LOW (unless web3 contracts) |
| **Soundwave** | Planning | Engagement interview, OPPLAN generation | ⭐⭐⭐ HIGH — compliance workflow orchestration |
| **Decepticon** | Orchestrator | Main loop, agent delegation | ⭐⭐ MEDIUM — workflow engine |
| **Detector** | Vuln Research | Promotes candidates to vulns | ⭐⭐ MEDIUM |
| **Vuln Research** | Pipeline | Multi-stage vulnerability research | ⭐⭐ MEDIUM |

---

## Components Extractable for cmmc20

### 🔴 HIGH VALUE — Extract & Adapt

#### 1. Knowledge Graph (Neo4j)
**File:** `decepticon/tools/research/graph.py`, `decepticon/tools/research/neo4j_store.py`

**What it does:**
- Typed node graph: Host, Service, Vulnerability, CVE, User, Credential, etc.
- Rich edge types: EXPLOITS, HAS_VULN, CAN_ACCESS, AUTHENTICATES_TO, etc.
- Neo4j-native with Python fallback for testing
- Deterministic node IDs (SHA1 of kind + canonical key)
- Append-mostly design with dedup

**For cmmc20:**
- **Map CMMC controls as nodes** — each of the 110 practices becomes a node
- **Map findings as edges** — FINDING → RELATES_TO → CMMC_Control
- **Attack chain scoring** — "This control would have prevented this attack path"
- **Compliance graph** — show relationships between controls, domains, and findings
- **Visual compliance dashboard** — Neo4j's graph visualization for the web UI

**Adaptation effort:** MEDIUM — extend NodeKind/EdgeKind with CMMC-specific types, add control-to-vulnerability mapping.

---

#### 2. Scanner Agent (Heuristic SAST)
**File:** `decepticon/tools/research/scanner_tools.py`

**What it does:**
- Regex-based source/sink analysis across huge codebases
- Sharded scanning (parallel, zero-coordination)
- Heuristic scoring: sink weight + source co-occurrence + hot directory bonus
- Emits scored CANDIDATE nodes for deeper analysis

**For cmmc20:**
- **Scan infrastructure configs** — not just code, but security configs, firewall rules, access policies
- **Automated evidence collection** — scan for MFA enforcement, encryption settings, logging configs
- **CMMC practice verification** — regex patterns for "is this control actually implemented?"
- **Low-cost triage** — cheap scans before expensive AI analysis

**Adaptation effort:** LOW-MEDIUM — the sharding and scoring framework is reusable; swap the regex tables for CMMC-specific patterns.

---

#### 3. CVE / OSV / EPSS Intelligence
**File:** `decepticon/tools/research/cve.py`

**What it does:**
- Fuses NVD (CVSS), OSV (package-level), and EPSS (exploit prediction) into one score
- Rate-limited, cached lookups
- Graceful degradation when offline

**For cmmc20:**
- **Vulnerability-to-control mapping** — which CMMC practices would have prevented this CVE?
- **Risk scoring for compliance gaps** — "Your unpatched system has a CVE with 0.87 EPSS (top 5%)"
- **Remediation prioritization** — rank fixes by real-world exploitability, not just CVSS
- **SI (System and Information Integrity) domain** — directly maps to CMMC SI practices

**Adaptation effort:** LOW — nearly drop-in, just add CMMC control mapping to CVE results.

---

#### 4. Engagement Workflow / OPPLAN Generation
**File:** `docs/engagement-workflow.md`, `decepticon/agents/soundwave.py`

**What it does:**
- Structured interview → generates RoE, ConOps, Deconfliction Plan, OPPLAN
- Objectives with dependencies, MITRE ATT&CK mapping, acceptance criteria
- Phase-based execution with human oversight

**For cmmc20:**
- **Compliance engagement workflow** — instead of pen testing, guide users through CMMC assessment
- **Auto-generate assessment plans** — Soundwave-style interview → compliance roadmap
- **Evidence collection OPPLAN** — "OBJ-001: Collect MFA evidence, depends on OBJ-000 (inventory)"
- **Remediation planning** — phased approach with dependencies and acceptance criteria
- **C3PAO readiness reports** — same document generation pattern, adapted for compliance

**Adaptation effort:** MEDIUM-HIGH — restructure the interview and document templates for compliance.

---

### 🟡 MEDIUM VALUE — Partial Extraction

#### 5. LLM Model Router
**File:** `decepticon/llm/models.py`, `decepticon/llm/router.py`

**What it does:**
- Tier-based model selection (HIGH/MID/LOW)
- Credentials-aware fallback chain
- Profile modes (eco/max/test)
- Supports Anthropic, OpenAI, Gemini, MiniMax, DeepSeek, xAI, Mistral, OpenRouter, Nvidia, Ollama

**For cmmc20:**
- **Cost optimization** — use cheap models for simple assessments, powerful models for complex gap analysis
- **Multi-provider resilience** — if one provider is down, fall back to another
- **Local model option** — Ollama for privacy-sensitive compliance data

**Adaptation effort:** MEDIUM — the model abstraction layer is well-designed and reusable.

---

#### 6. Middleware Stack
**File:** `decepticon/middleware/`

**What it does:**
- SkillsMiddleware — progressive disclosure of SKILL.md knowledge
- FilesystemMiddleware — sandbox file operations
- ModelFallbackMiddleware — provider resilience
- SummarizationMiddleware — context budget management
- PatchToolCallsMiddleware — error recovery

**For cmmc20:**
- **Skills-based compliance guidance** — load CMMC domain playbooks as skills
- **Context management** — long assessments need the same compaction
- **Error resilience** — compliance assessments must be robust

**Adaptation effort:** MEDIUM — the framework is reusable; content needs to be CMMC-specific.

---

#### 7. Attack Chain Planner
**File:** `decepticon/tools/research/chain.py`

**What it does:**
- Neo4j Cypher path search from Entrypoint → CrownJewel
- Weighted cost model (severity, validation state, edge difficulty)
- Produces ranked attack paths

**For cmmc20:**
- **Control dependency mapping** — "If access control fails, which data protection controls are also compromised?"
- **Compliance chain analysis** — show which controls protect which assets
- **Risk propagation** — one failing control cascades to others
- **Visual risk paths** — show customers the "attack path" through their compliance gaps

**Adaptation effort:** MEDIUM — repurpose as a "compliance gap propagation" engine.

---

### 🟢 LOWER VALUE — Reference Only

#### 8. Exploitation Agents (Exploit, Exploiter, AD Operator)
- Beyond typical CMMC scope
- Could be used for premium "offensive validation" tier
- Legal/compliance considerations for offering automated exploitation

#### 9. C2 Framework (Sliver)
- Red team infrastructure, not compliance-relevant
- Only useful if offering active red teaming as a service

#### 10. Reverser / Contract Auditor
- Niche use cases
- Only relevant for specific contractor industries

---

## Recommended Integration Roadmap

### Phase 1: Foundation (Weeks 1-2)
1. **Extract Knowledge Graph** — Adapt NodeKind/EdgeKind for CMMC controls
2. **Extract CVE integration** — Add CMMC control mapping to vulnerability lookups
3. **Extract Scanner framework** — Adapt heuristic scanning for config/infra analysis
4. **Set up Neo4j** — Add to cmmc20's infrastructure

### Phase 2: Compliance Engine (Weeks 3-4)
1. **CMMC Node Types** — ControlNode, DomainNode, EvidenceNode, FindingNode
2. **Control-to-Vuln Mapping** — Map CVEs/CWEs to relevant CMMC practices
3. **Config Scanning** — Regex patterns for MFA, encryption, logging, access controls
4. **Risk Scoring** — Adapt attack chain scoring for compliance gap severity

### Phase 3: Workflow Integration (Weeks 5-6)
1. **Compliance Interview** — Adapt Soundwave's engagement interview for CMMC assessment
2. **Evidence Collection OPPLAN** — Phase-based evidence gathering with dependencies
3. **Gap Analysis Reports** — Auto-generate C3PAO-ready documentation
4. **Web Dashboard** — Graph visualization of compliance posture

### Phase 4: Premium Features (Weeks 7-8)
1. **Red Team Validation** — Optional: run Decepticon's recon against customer infra
2. **Continuous Monitoring** — Periodic re-scans to verify compliance drift
3. **Remediation Guidance** — AI-powered fix suggestions (already in cmmc20, enhanced)

---

## Technical Considerations

### What to Extract (Copy)
- `decepticon/tools/research/graph.py` — Node/Edge schema, KnowledgeGraph class
- `decepticon/tools/research/neo4j_store.py` — Neo4j persistence layer
- `decepticon/tools/research/cve.py` — CVE/OSV/EPSS integration
- `decepticon/tools/research/scanner_tools.py` — Sharded scanning framework
- `decepticon/tools/research/chain.py` — Path scoring and ranking
- `decepticon/llm/models.py` — Model tier/fallback system
- `decepticon/middleware/` — Middleware framework

### What to Adapt (Modify)
- NodeKind/EdgeKind enums → add CMMC-specific types
- Scanner regex tables → security config patterns
- Engagement interview → compliance assessment questions
- OPPLAN structure → evidence collection plan
- Attack chain scoring → compliance gap scoring

### What to Skip
- DockerSandbox (cmmc20 doesn't need shell access for most features)
- C2 framework integration
- Exploitation agents
- Binary analysis tools

### Dependencies to Add
```
neo4j>=5.0
httpx
pydantic
langchain-core (if using middleware)
```

---

## Questions for ShadowFox

1. **Scope**: Should cmmc20 offer red team validation as a premium tier, or just compliance assessment?
2. **Neo4j**: Add Neo4j to cmmc20's stack, or use a lighter graph solution (SQLite + graph lib)?
3. **Priority**: Which phase should we tackle first?
4. **Hermes**: How does this relate to the Hermes setup we're also pursuing?

---

*Analysis by CatClaw 🐱 — 2026-05-07*
