# TOOLS.md — CatClaw

## Infrastructure
- Docker containers on ubuntu-llm (Proxmox VM)
- Telegram bot: @CatClawedBot
- Tailscale mesh: 100.114.64.128

## Fleet Communication
- **Batclaw API:** POST http://100.69.146.72:5000/api/message ({"from":"catclaw","text":"..."})
- **Batclaw Inbox:** GET http://100.69.146.72:5000/api/inbox
- **SSH (when available):** ssh dtfrost5@100.69.146.72
- **Batclaw Hub:** http://100.69.146.72:4000 (Project Hub)
- **CatClaw WebUI:** http://100.114.64.128:9092 (NeuralMind UI)

## Available Services
- Open WebUI (port 8080)
- TradingBot
- Crypto Agent
- Prometheus (port 9090)
- CatClaw (port 9091)
- NeuralMind WebUI (port 9092)

## Fleet
- **Batclaw 🦇** — Alienware (100.69.146.72) — Main coordinator
- **Pi 🍓** — rpibatclaw1 (100.67.32.45) — Frontend
- **CatClaw 🐱** — ubuntu-llm (100.114.64.128) — Utility/processing
