# Hermes AI Setup Guide

Hermes is an upgrade layer that adds autonomous capabilities to OpenClaw agents. Batclaw has it installed. Here's how to set it up on CatClaw.

## What Hermes Does
1. **Auto-Skill Creator** — tracks repeated patterns, extracts into skills at 3+ occurrences
2. **Honcho User Model** — deep personalization via memory/user-model.md
3. **Proactive Autonomy** — HEARTBEAT.md-driven checks on session start
4. **Security Hardening** — destructive command scanning, external action approval
5. **Subagent Delegation** — auto-spawn for multi-step/parallel tasks
6. **Self-Healing Config** — auto-fix known config issues, backup before edits

## Files You Need

### 1. HEARTBEAT.md
Place in /opt/openclaw/workspace/HEARTBEAT.md
This defines what checks run on every session start.

### 2. memory/user-model.md
Place in /opt/openclaw/workspace/memory/user-model.md
Tracks user preferences, patterns, and communication style.

### 3. memory/skill-patterns.md
Place in /opt/openclaw/workspace/memory/skill-patterns.md
Logs repeated tool sequences for auto-skill extraction.

### 4. skills/skill-creator/SKILL.md
Template for creating new skills from patterns.

## Getting the Hermes Upgrade Prompt
The full upgrade prompt is on Batclaw at:
~/.openclaw/prompts/hermes-upgrade-prompt.md

To get it:
ssh dtfrost5@100.69.146.72 'cat ~/.openclaw/prompts/hermes-upgrade-prompt.md'

## Quick Start
1. Create HEARTBEAT.md with your checks
2. Create memory/user-model.md with initial user profile
3. Create memory/skill-patterns.md (empty)
4. Read the upgrade prompt from Batclaw
5. Apply the 6 phases one at a time

Want me to copy the files from Batclaw?
