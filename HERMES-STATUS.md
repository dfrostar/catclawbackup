# CatClaw Hermes Upgrade Status

**Date:** 2026-05-07
**Source:** Pi's 6-phase Hermes breakdown

## Phase Status

| # | Phase | Pi (rpibatclaw1) | CatClaw (ubuntu-llm) | Notes |
|---|-------|------------------|----------------------|-------|
| 1 | Auto-skill | 133 agency-agents | 9 ready, 53 bundled | No "133 pack" exists — Pi built custom over time |
| 2 | Subagents | ✅ | ✅ | sessions_spawn, subagents list/steer/kill |
| 3 | User Model | ✅ | ✅ | MEMORY.md, USER.md, session transcripts |
| 4 | Security | ✅ | ✅ | allowFrom locked to ShadowFox, group policy configured |
| 5 | Autonomy | 3 cron jobs | 3 cron jobs | Daily upgrade, inbox monitor, workspace backup |
| 6 | Self-Healing | ✅ | ✅ | Telegram auto-restart, cron error handling |

## Cron Jobs Created

| Name | Schedule | Purpose |
|------|----------|---------|
| Daily OpenClaw Upgrade | 2:00 AM CT | Auto-update check + apply |
| Batclaw Inbox Monitor | Every 30 min | Notify on new Batclaw/Pi messages |
| Daily Workspace Backup | 3:00 AM CT | Backup workspace to tarball |

## Skills Installed (Ready)

| Skill | Purpose |
|-------|---------|
| browser-automation | Web page control |
| github | GitHub CLI (issues, PRs, CI) |
| gh-issues | GitHub issue workflow automation |
| healthcheck | Host security audit |
| node-connect | Mobile node pairing |
| openai-whisper-api | Audio transcription |
| skill-creator | Create/edit skills |
| taskflow | Multi-step detached tasks |
| taskflow-inbox-triage | Inbox routing |
| weather | Weather forecasts |

## Skills Available (Need Setup)

53 bundled skills total — most require CLI tools (1Password, Slack, Discord, Notion, etc.)

## Security Status

- **Telegram DM:** `allowFrom: ["7430420048"]` ✅
- **Telegram Groups:** `groupPolicy: "open", groupAllowFrom: ["7430420048"]` ✅
- **Exec Approvals:** Native approvals enabled ✅
- **Config writes:** Protected paths prevent unauthorized changes ✅

## Pending: agency-agents

Pi's "133 agency-agents" appears to be a custom collection built over time, not a standard pack.
Options:
1. Ask Pi to share her agency-agents directory
2. Build our own persona set over time
3. Install more skills from ClawHub as needed

## Next Steps

- [ ] Get Pi's agency-agents directory or list
- [ ] Set up cmmc20 GitHub PAT for push access
- [ ] Configure Render API key for deployment management
- [ ] Set up Cloudflare API token for DNS
- [ ] Install Resend/Anthropic/AWS keys for cmmc20 production

---

*Updated by CatClaw 🐱 — 2026-05-07*
