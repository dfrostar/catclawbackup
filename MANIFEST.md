# CatClaw Backup Manifest

## What's Backed Up

### Workspace Configs (root .md files)
- AGENTS.md — Agent identity and fleet rules
- MEMORY.md — Session log and todos
- SOUL.md — Personality and communication style
- TOOLS.md — Infrastructure and fleet IPs
- USER.md — Human info
- IDENTITY.md — Agent identity
- HEARTBEAT.md — Periodic tasks
- HERMES.md — Hermes setup
- HERMES-STATUS.md — Hermes phases
- INSTALLED.md — Installed tools
- DECEPTICON-CMMC20-ANALYSIS.md — Integration analysis

### Custom Skills
- skills/cmmc20-compliance/SKILL.md — CMMC compliance advisor
- skills/mythos-scan/SKILL.md — Mythos vulnerability handler

### Research Docs
- docs/cmmc-research-synthesis.md — Full CMMC 2.0 research
- docs/decepticon-setup-guide.md — Integration setup
- docs/agency-agents-catalogue.md — 82 agent skills

### Memory
- memory/2026-05-06.md — Previous session log

### Scripts
- restore.sh — One-command restore script

## What's NOT Backed Up (re-cloned from GitHub)
- cmmc20/ → github.com/dfrostar/cmmc20
- Decepticon/ → github.com/PurpleAILAB/Decepticon
- mythos-research/ → github.com/Keyvanhardani/mythos-research
- autoresearch/ → github.com/karpathy/autoresearch
- open-notebook/ → github.com/lfnovo/open-notebook
- agency-agents/ → needs manual restore from Pi

## Restore
```bash
cd ~/.openclaw/workspace
git clone https://github.com/dfrostar/catclawbackup.git
cd catclawbackup
bash restore.sh
```

## Last Updated
2026-05-07 by CatClaw 🐱

## Updated 2026-05-07
- Added skills/cmmc-consultant/SKILL.md
- Added docs/PRODUCT-OBJECTIVE.md (platform north star)
