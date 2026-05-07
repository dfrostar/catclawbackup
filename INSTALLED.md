# Already Installed — Do NOT Rebuild

## Tools & CLI
- ✅ Claude Code CLI — /usr/bin/claude
- ✅ NeuralMind — ~/neuralmind-venv/bin/neuralmind
- ✅ Graphify — ~/.local/bin/graphify (pipx)
- ✅ OpenClaw — Docker container (port 9091)
- ✅ gh (GitHub CLI) — NOT installed, use git

## NeuralMind Indexes (Do NOT Rebuild)
- ✅ Workspace — 2,900 nodes at /opt/openclaw/workspace/graphify-out/
- ✅ cmmc20 — 1,080 nodes at /opt/openclaw/workspace/cmmc20/graphify-out/

## Graphify Graphs (Do NOT Rebuild)
- ✅ Workspace — graph.json at /opt/openclaw/workspace/graphify-out/
- ✅ cmmc20 — graph.json at /opt/openclaw/workspace/cmmc20/graphify-out/

## Projects Cloned
- ✅ cmmc20 — /opt/openclaw/workspace/cmmc20/
- ✅ mythos-research — /opt/openclaw/workspace/mythos-research/

## Agents Installed
- ✅ 81 agency agents at /opt/openclaw/workspace/agency-agents/

## Docker Services Running
- ✅ openclaw (port 9091)
- ✅ open-webui (port 8080)
- ✅ ibkr-traderbot
- ✅ crypto_agent (port 3001)
- ✅ crypto_prometheus (port 9090)

## Systemd Services
- ✅ catclaw.service — auto-starts OpenClaw on boot
- ✅ docker.service — enabled

## SSH & Network
- ✅ Tailscale v1.96.4 — IP 100.114.64.128
- ✅ SSH keys — can reach Batclaw (100.69.146.72) and Pi (100.67.32.45)
- ✅ Telegram bot — @CatClawedBot

## Config
- ✅ AGENTS.md — configured for cmmc20 ownership
- ✅ SOUL.md — configured
- ✅ TOOLS.md — configured
- ✅ .bashrc — PATH includes ~/.local/bin

## What You CAN Do
- Run tests on cmmc20
- Monitor deployments
- Report to Telegram group
- Send updates to Batclaw via API (http://100.69.146.72:5000/api/message)

## What Batclaw Handles
- Mythos vulnerability scans
- Cron job management
- Project Shepherd daily digests
- Crucix OSINT
- Upgrade protection
